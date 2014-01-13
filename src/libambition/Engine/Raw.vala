/*
 * Raw.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2013 Sensical, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

using Gee;

extern void exit(int code);

namespace Ambition.Engine {

	static const int NUM_THREADS = 10;
	private static const uint16 PORT = 8099;
	
	/**
	 * Raw engine, implemented using sockets.
	 */
	public class Raw : Base {
		
		private int count = 0;
		
		private enum ConnectionResult {
			BROKEN,
			CLOSE,
			KEEPALIVE
		}
		
		private static Regex INITIAL_LINE_RE = /^(\S+) (\S+) HTTP\/(\d+)\.(\d+)$/;
		private static Regex HEADER_RE = /^([^:]+): (.*)$/;
		private static Regex HOST_FROM_PATH_RE = /^https?:\/\/([^\/]+)(.*?)$/;
				
		private static string[] ACCEPTED_METHODS = { "GET", "HEAD", "POST" };

		public override string name { get { return "Raw"; } }
		
		private static string local_addr_from_connection ( SocketConnection conn ) {
			// for HTTP 1.0 requests. there might be one, right?
			try {
				return ((InetSocketAddress) conn.get_local_address()).get_address().to_string();
			} catch (Error e) {
				Logger.error("couldn't get local address for connection: " + e.message);
				return "";
			}
			
			// for future reference, the hostname would be:
			// Resolver.get_default().lookup_by_address[_async](
			//   ((InetSocketAddress) conn.get_local_address()).get_address() )
		}

		public override void execute() {
			var service = new ThreadedSocketService(-1);
			try {
				service.add_inet_port( PORT, null );
			} catch (Error inet_err) {
				Logger.error( "Couldn't bind to port: " + inet_err.message );
				exit(-1);
			}
			Logger.info( "Starting Raw engine on port %d".printf(PORT) );
			service.run.connect(handler);				
			service.start();
			
			new MainLoop().run();
		}
		
		private bool handler( SocketConnection conn, Object? source_object ) {
			Logger.debug("Accepted connection");
			process_conn.begin( conn, (count++).to_string() );
			return true;
		}
		
		private async void process_conn( SocketConnection conn, string id ) {
			State state = null;
			ConnectionResult result = ConnectionResult.KEEPALIVE;
			DateTime start;
			
			while ( result == ConnectionResult.KEEPALIVE ) {
				if ( state != null ) {
					state.log.info("Reusing connection for new request");
				}
				
				start = new DateTime.now_utc();
				state = this.dispatcher.initialize_state(id);

				try {
					result = yield process_request(conn, state);
				} catch ( IOError e ) {
					state.log.info( "IO Error: " + e.message );
					conn.close_async.begin();
					return;
				}

				if ( result != ConnectionResult.BROKEN ) {
					this._after_request(state);
					this.dispatcher.handle_request(state);
					this._after_render(state);
				}

				state.start = start;
				try {
					yield process_response(conn, state, result);
				} catch ( IOError e2 ) {
					state.log.info("IO Error: " + e2.message);
					conn.close_async.begin();
					return;
				} 
				state.log.info( "Complete in-engine time: %0.4f ms".printf( state.elapsed_ms() ) );
				
				// some people close anyway
				if ( conn.input_stream.is_closed() ) {
					state.log.info("connection was closed by other side");
					result = ConnectionResult.CLOSE;
				}
			}
			
			state.log.info("closing connection");
			conn.close_async.begin();
		}
		
		private async void send_continue_async( SocketConnection conn ) {
			try {
				conn.output_stream.write("HTTP/1.1 100 Continue\r\n\r\n".data);
			} catch (IOError e) {
				// oh well, process_request will find out soon enough...
			}
		}
		
		private async ConnectionResult process_request( SocketConnection conn, State state ) throws IOError {
			DataInputStream data_in = new DataInputStream(conn.input_stream);
			
			MatchInfo m;
			bool got_init = false;
			int content_length = 0;
			string? req_path = "", method = "", maj_v = "", min_v = "", content_type = null;
			var headers = new HashMap<string,string>();
						
			string line;
			while ( ( line = data_in.read_line( null, null ) ) != null ) {
				if (!got_init) {
					if ( INITIAL_LINE_RE.match( line, 0, out m ) ) {
						method = m.fetch(1);
						if ( !( method in ACCEPTED_METHODS ) ) {
							state.log.debug( "not accepted method:" + method );
							state.response.status = 501;
							return ConnectionResult.BROKEN;
						}
						req_path = m.fetch(2);
						maj_v = m.fetch(3);
						min_v = m.fetch(4);
						if ( maj_v != "1" ) {
							state.response.status = 505;
							return ConnectionResult.BROKEN;
						}
						if ( min_v != "0" ) {
							send_continue_async.begin(conn);
						}
						state.log.debug(
							"Request %s for %s - version %s.%s",
							method,
							req_path,
							maj_v,
							min_v
						);
						got_init = true;
						continue;
					} else {
						// non-matching first line
						state.log.debug("didn't match first line");
						state.response.status = 400;
						return ConnectionResult.BROKEN;
					}
				}
				
				// after initial line
				if ( HEADER_RE.match(line, 0, out m) ) {
					headers[m.fetch(1)] = m.fetch(2);
				} else {
					// this must be a blank line or something's wrong.
					if ( line == "\r" || line == "" ) {
						// check sanity
						bool sane = true;
						switch (min_v) {
							case "0":
								headers["Host"] = local_addr_from_connection(conn);
								break;
							case "1":
								sane = headers.has_key("Host");
								break;
							default:
								string[] split = split_path(req_path);
								if (split.length == 0) {
									sane = false;
								} else {
									headers["Host"] = split[0];
									req_path = split[1];
								}
								break;
						}
						if (!sane) {
							state.log.debug("insane request");
							state.response.status = 400;
							return ConnectionResult.BROKEN;
						}
						
						if (headers["Transfer-Encoding"] == "chunked") {
							// TODO wtf weird client
							state.log.debug("chunked encoding ugh");
							state.response.status = 500;
							return ConnectionResult.BROKEN;
						}
						
						if ( headers.has_key("Content-Type") ) {
							content_type = headers["Content-Type"];
						}
						
						if ( headers.has_key("Content-Length") ) {
							content_length = int.parse(headers["Content-Length"]);
						}
						break;
					} else {
						state.log.debug("line didn't match after headers. line was <%s>. sending 400", line);
						state.response.status = 400;
						return ConnectionResult.BROKEN;
					}
				}
			}

			string remote_ip = "";
			try {
				remote_ip = ((InetSocketAddress) conn.get_remote_address()).get_address().to_string();
			} catch (Error addr_err) {
				state.log.error("trying to read remote address: " + addr_err.message);
			}
			
			string raw_path = req_path;
			var params = new HashMap<string,string>();
			if ( method == "GET" ) {
				int query_start = req_path.index_of("?");
				if ( query_start != -1 ) {
					string query = req_path[query_start + 1 : req_path.length];
					
					if (query_start == 0) {
						req_path = "";
					} else {
						req_path = req_path[0 : query_start];
					}
					
					params = Ambition.Request.params_from_string(query);
				}
			}
			
			state.request.initialize(
				HttpMethod.from_string(method), 
				remote_ip,
				"http",
				headers["Host"],
				raw_path,
				req_path,
				params,
				headers,
				content_type
			);
			state.request.user_agent = headers["User-Agent"];

			if ( content_length > 0 ) {
				hook_parse_request_body( state, content_length, data_in );
			}
			
			if ( headers["Connection"] == "keep-alive" ) {
				return ConnectionResult.KEEPALIVE;
			} else {
				return ConnectionResult.CLOSE;
			}
		}
		
		private async void process_response( SocketConnection conn, State state, ConnectionResult result ) throws IOError {
			// status
			yield conn.output_stream.write_async(
				"HTTP/1.1 %i %s\r\n".printf( state.response.status, STATUS_TEXT[state.response.status] ).data
			);
			
			var raw_headers = new HashMap<string,string>();

			raw_headers["Date"] = new DateTime.now_utc().format("%a, %d %b %Y %H:%M:%S %Z");
			raw_headers["Connection"] = (result == ConnectionResult.KEEPALIVE ? "keep-alive" : "close");
			if ( state.response.get_body_length() > 0 ) {
				raw_headers["Content-Type"] = state.response.content_type;
				raw_headers["Content-Length"] = state.response.get_body_length().to_string();
			}

			raw_headers.set_all(state.response.headers);
			
			foreach ( var header_key in raw_headers.keys ) {
				yield conn.output_stream.write_async(
					"%s: %s\r\n".printf( header_key, raw_headers[header_key] ).data
				);
			}
			
			yield conn.output_stream.write_async("\r\n".data);
			
			if ( state.request.method != HttpMethod.HEAD && state.response.get_body_length() > 0 ) {
				yield conn.output_stream.splice_async(
					state.response.get_body_data(),
					OutputStreamSpliceFlags.CLOSE_SOURCE
				);
			}

		}
		
		private string[] split_path( string path ) {
			MatchInfo m;
			string[] r = new string[2];
			if ( HOST_FROM_PATH_RE.match(path, 0, out m) ) {
				r = { m.fetch(1), m.fetch(2) };
			} else {
				r = {};
			}
			return r;
		}

	}
}
