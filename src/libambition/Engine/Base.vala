/*
 * Base.vala
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

using Ambition;
using Gee;

namespace Ambition.Engine {
	/**
	 * Base class for an Engine implementation.
	 */
	public class Base : Component {
		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.Engine.Base");

		public virtual string name { get { return ""; } }

		protected static HashMap<int,string> STATUS_TEXT = new HashMap<int,string>();
		
		static construct {
			STATUS_TEXT[100] = "Continue";
			STATUS_TEXT[101] = "Switching Protocols";
			STATUS_TEXT[200] = "OK";
			STATUS_TEXT[201] = "Created";
			STATUS_TEXT[202] = "Accepted";
			STATUS_TEXT[203] = "Non-Authoritative Information";
			STATUS_TEXT[204] = "No Content";
			STATUS_TEXT[205] = "Reset Content";
			STATUS_TEXT[206] = "Partial Content";
			STATUS_TEXT[300] = "Multiple Choices";
			STATUS_TEXT[301] = "Moved Permanently";
			STATUS_TEXT[302] = "Found";
			STATUS_TEXT[303] = "See Other";
			STATUS_TEXT[304] = "Not Modified";
			STATUS_TEXT[305] = "Use Proxy";
			STATUS_TEXT[307] = "Temporary Redirect";
			STATUS_TEXT[400] = "Bad Request";
			STATUS_TEXT[401] = "Unauthorized";
			STATUS_TEXT[402] = "Payment Required";
			STATUS_TEXT[403] = "Forbidden";
			STATUS_TEXT[404] = "Not Found";
			STATUS_TEXT[405] = "Method Not Allowed";
			STATUS_TEXT[406] = "Not Acceptable";
			STATUS_TEXT[407] = "Proxy Authentication Required";
			STATUS_TEXT[408] = "Request Timeout";
			STATUS_TEXT[409] = "Conflict";
			STATUS_TEXT[410] = "Gone";
			STATUS_TEXT[411] = "Length Required";
			STATUS_TEXT[412] = "Precondition Failed";
			STATUS_TEXT[413] = "Request Entity Too Large";
			STATUS_TEXT[414] = "Request-URI Too Long";
			STATUS_TEXT[415] = "Unsupported Media Type";
			STATUS_TEXT[416] = "Requested Range Not Satisfiable";
			STATUS_TEXT[417] = "Expectation Failed";
			STATUS_TEXT[500] = "Server Error";
			STATUS_TEXT[501] = "Not Implemented";
			STATUS_TEXT[502] = "Bad Gateway";
			STATUS_TEXT[503] = "Service Unavailable";
			STATUS_TEXT[504] = "Gateway Timeout";
			STATUS_TEXT[505] = "HTTP Version Not Supported";
		}
		
		/**
		  * every overriding engine MUST at the very least do the following.
		
			foreach (Connection) { 
				state = this.dispatcher.initialize_state(id);

				state.request.initialize(
					method, remote_ip, "http", headers["Host"], raw_path, req_path, params, headers
				);

				this._after_request(state);
				this.dispatcher.handle_request( state );
				this._after_render(state);

				// write status
				// write headers
				// write body if necessary
			}
		 */
		public virtual void execute() {}
		
		protected virtual void _after_request( State state ) {
			hook_parse_request_cookies(state);
		}
		
		protected virtual void _after_render( State state ) {
			hook_set_cookies(state);
		}

		/**
		 * Called while parsing the request, reads input and fills request body
		 * or provides file handles to uploads.
		 * @param state State
		 */
		public virtual void hook_parse_request_body( State state, int content_length, DataInputStream stream ) {
			if ( state.request.content_type != null && "multipart/form-data" in state.request.content_type ) {
				mime_decode( state, stream );
			} else {
				parse_form_data( state, content_length, stream );
			}
		}

		private void parse_form_data( State state, int content_length, DataInputStream stream ) {
			uint8[] post_data = new uint8[content_length];
			uint32 index = 0;
			uint8 c;
			try {
				while ( ( c = stream.read_byte(null) ) != 0 ) {
					if ( c == '\r' ) {
						break;
					}
					if ( c == '\n' && index == 0 ) {
						continue;
					}
					post_data[index++] = c;
					if ( index == content_length ) {
						break;
					}
				}
			} catch (IOError e) {}
			if ( index > 0 ) {
				state.request.params.set_all( Request.params_from_string( (string) post_data ) );
				state.request.request_body = post_data;
			}
		}

		private void mime_decode( State state, DataInputStream stream ) {
			string boundary = null;
			if ( "boundary=" in state.request.content_type ) {
				MatchInfo info;
				if ( /boundary="?(.*?)[" ;]?$/.match( state.request.content_type, 0, out info ) ) {
					boundary = "--" + info.fetch(1);
				}
			}

			if ( boundary != null ) {
				string line = "";
				while ( 1 == 1 ) {
					size_t length;
					try {
						line = stream.read_upto( "\r", -1, out length, null );
						var trash = stream.read_byte();
						trash = stream.read_byte();
					} catch (IOError e) {}
					if ( line == null ) {
						break;
					}
					if ( boundary in line ) {
						mime_parse_boundary( state, stream, boundary );
					}
				}
			}
		}

		private void mime_parse_boundary( State state, DataInputStream stream, string boundary ) {
			string line = "";
			string content_disposition = null;
			string name = null;
			string content_type = null;
			string file_name = null;
			string encoding = null;
			while ( 1 == 1 ) {
				size_t length;
				try {
					line = stream.read_upto( "\r", -1, out length, null );
					// Skip CRLF
					var trash = stream.read_byte();
					trash = stream.read_byte();
				} catch (IOError e) {}
				if ( line == null ) {
					break;
				}
				var fline = line.chug();
				if ( fline == "" ) {
					break;
				}
				string[] split = fline.split(": ");
				switch( split[0] ) {
					case "Content-Disposition":
						string val = split[1].substring( 0, split[1].index_of(" ") ).replace( ";", "" ).replace( "\"", "" );
						content_disposition = val;
						MatchInfo info;
						if ( /name="?(.*?)[" ;\b]/.match( split[1], 0, out info ) ) {
							name = info.fetch(1);
						}
						if ( /filename="?(.*?)[" ;\b]/.match( split[1], 0, out info ) ) {
							file_name = info.fetch(1);
						}
						break;
					case "Content-Type":
						string val = split[1].substring( 0, split[1].index_of(" ") ).replace( ";", "" ).replace( "\"", "" );
						content_type = val;
						break;
					case "Content-Transfer-Encoding":
						encoding = split[1];
						break;
				}
			}
			if ( content_disposition != null ) {
				if ( content_disposition == "form-data" && ( file_name == null || file_name == "" ) ) {
					parse_form_data( state, 16384, stream );
				} else if ( file_name != null ) {
					parse_file_data( state, stream, boundary, content_disposition, name, content_type, file_name, encoding );
					// Manually kick off parser again, since parse_file_data ate the boundary.
					try {
						var trash = stream.read_byte();
						if ( trash > 0 ) {}
						mime_parse_boundary( state, stream, boundary );
					} catch (IOError e) {}
				}
			}
		}

		private void parse_file_data( State state, DataInputStream stream, string boundary, string content_disposition, string? name, string content_type, string file_name, string? encoding ) {
			uint8 c;
			int read = 0;
			bool ready = false;
			string new_boundary = "\r\n%s".printf(boundary);
			int len = new_boundary.length;
			uint8[] boundaryish = new uint8[len];
			string req_file_name = ( name != null ? name : ( file_name != null ? file_name : "unknown" ) );
			FileIOStream iostream;
			File temp_file; 
			try {
				temp_file = File.new_tmp( "amb-upload-XXXXXX.tmp", out iostream );
			} catch (Error e) {
				logger.error( "Cannot create temp file for incoming file", e );
				return;
			}
			DataOutputStream dos = new DataOutputStream( iostream.output_stream );
			try {
				while ( ( c = stream.read_byte(null) ) != 0 ) {
					if ( (string) boundaryish == new_boundary ) {
						break;
					}

					/*
					 * Keep a buffer of the length of the MIME boundary, and
					 * fill it before outputting bytes to the output file.
					 */
					if ( ready ) {
						dos.put_byte( boundaryish[0] );
					}
					for ( var i = 1; i < len; i++ ) {
						boundaryish[i - 1] = boundaryish[i];
					}
					boundaryish[ len - 1 ] = c;
					if ( ready == false ) {
						if ( read < len ) {
							read++;
						}
						if ( read == len ) {
							ready = true;
						}
					}
				}
			} catch (IOError e) {}
			state.request.files[req_file_name] = new RequestFile.with_contents( file_name, content_type, temp_file );
		}

		/**
		 * Called while parsing the request, generates cookie list in request
		 * object.
		 * @param state State
		 */
		public virtual void hook_parse_request_cookies( State state ) {
			string raw_cookie_list = state.request.header("HTTP_COOKIE");
			if ( raw_cookie_list == null ) {
				raw_cookie_list = state.request.header("Cookie");
			}

			if ( raw_cookie_list != null ) {
				string[] raw_cookies = raw_cookie_list.split("; ");
				foreach ( string raw_cookie in raw_cookies ) {
					string[] pair = raw_cookie.split("=");
					var c = new Cookie();
					c.name = pair[0];
					c.value = pair[1];
					state.request.set_cookie(c);
				}
			}
		}

		/**
		 * Called after rendering output, converts Response cookies to cookie
		 * headers.
		 * @param state State
		 */
		public virtual void hook_set_cookies( State state ) {
			var sb = new StringBuilder();
			foreach ( Cookie cookie in state.response.cookies.values ) {
				if ( sb.len > 0 ) {
					sb.append("; ");
				}
				string? cookie_string = cookie.render();
				if ( cookie_string != null ) {
					sb.append(cookie_string);
				}
			}
			state.response.set_header( "Set-Cookie", sb.str );
		}
	}
}
