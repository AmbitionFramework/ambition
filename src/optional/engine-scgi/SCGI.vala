/*
 * SCGI.vala
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
using scgi;

namespace Ambition.Engine {
	/**
	 * Threaded SCGI Engine implementation, requiring libgscgi.
	 */
	public class SCGI : Base {

		public override string name {
			get { return "SCGI"; }
		}

		public override void execute() {
			uint16 port = (uint16) int.parse( Config.lookup_with_default( "scgi.port", "3200" ) );
			int threads = int.parse( Config.lookup_with_default( "scgi.threads", "10" ) );
			Logger.info( "Starting SCGI engine with %d threads on port %d.".printf( threads, port ) );
			new scgi.Server( port, threads, request_handler );
		}

		private void request_handler( scgi.Request scgi_req ) {
			if ( scgi_req.params.size() == 0 ) {
				Logger.error("Request received without headers. Server may be misconfigured.");
				return;
			}
			
			State state = this.dispatcher.initialize_state("scgi");
			
			var headers = new HashMap<string,string>();
			foreach ( string k in scgi_req.params.get_keys() ) {
				headers[k] = scgi_req.params[k];
			}
			
			string protocol = scgi_req.params["SERVER_PROTOCOL"];
			int i;
			if ( (i = protocol.index_of("/")) != -1 ) {
				protocol = protocol[0:i];
			}
			protocol = protocol.down();
			

			var method = scgi_req.params["REQUEST_METHOD"];
			var request_params = Request.params_from_string( scgi_req.params["QUERY_STRING"] );
			var content_type = scgi_req.params["CONTENT_TYPE"];
			int content_length = int.parse( scgi_req.params["CONTENT_LENGTH"] );

			state.request.initialize(
				HttpMethod.from_string(method),
				scgi_req.params["REMOTE_ADDR"],
				protocol,
				scgi_req.params["HTTP_HOST"],
				scgi_req.params["REQUEST_URI"],
				scgi_req.params["DOCUMENT_URI"],
				request_params,
				headers,
				content_type
			);
			
			if ( content_length > 0 ) {
				var stream = new DataInputStream( scgi_req.input );
				hook_parse_request_body( state, content_length, stream );
			}
			
			this._after_request(state);
			this.dispatcher.handle_request( state );
			this._after_render(state);
			
			write_response(scgi_req, state);
		}
		
		private void write_response( scgi.Request scgi_req, State state ) {
			scgi_req.output.write(
				"HTTP/1.1 %i %s\r\n".printf(state.response.status, STATUS_TEXT[state.response.status]).data
			);
			
			var raw_headers = new HashMap<string,string>();
			raw_headers.set_all(state.response.headers);
			
			raw_headers["Date"] = new DateTime.now_utc().format("%a, %d %b %Y %H:%M:%S %Z");
			if ( state.response.body != null ) {
				raw_headers["Content-Type"] = state.response.content_type;
				raw_headers["Content-Length"] = state.response.get_body_length().to_string();
			}
			
			var it = raw_headers.map_iterator();
			for (var has_next = it.first(); has_next; has_next = it.next()) {
				scgi_req.output.write(
					"%s: %s\r\n".printf( it.get_key(), it.get_value() ).data
				);
			}
			
			scgi_req.output.write("\r\n".data);
			
			if ( state.request.method != HttpMethod.HEAD && state.response.get_body_length() > 0 ) {
				scgi_req.output.splice( state.response.get_body_data(), OutputStreamSpliceFlags.CLOSE_SOURCE  );
			}
		}
	}
}
