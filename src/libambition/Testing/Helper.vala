/*
 * Helper.vala
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
namespace Ambition.Testing {
	/**
	 * Helper methods for testing an Ambition application.
	 */
	public class Helper : Object {

		/**
		 * Retrieve a mock State object.
		 * @param id Optional request ID, defaults to "test".
		 */
		public static State get_mock_state( string id = "test" ) {
			var state = new State(id);
			state.dispatcher = null;
			state.request = new Request();
			state.response = new Response();

			return state;
		}

		/**
		 * Perform a mock request against a given path. Runs through the
		 * dispatcher without launching the full application.
		 * @param app Instance of the application to test.
		 * @param method HttpMethod for the request
		 * @param path URI path to request
		 * @param config_override Optionally provide a HashMap containing config
		 * overrides for this request.
		 */
		public static TestResponse mock_dispatch( Application app, HttpMethod method, string path, HashMap<string,string>? config_override = null ) {
			var request = new Request();
			request.initialize(
				method,
				"127.0.0.1",
				"http",
				"localhost",
				path,
				( path.index_of("?") > -1 ? path.substring( 0, path.index_of("?") ) : path ),
				new HashMap<string,string>(),
				new HashMap<string,string>()
			);
			return mock_dispatch_with_request( app, request, config_override );
		}

		/**
		 * Perform a mock request against a given request. Runs through the
		 * dispatcher without launching the full application.
		 * @param app Instance of the application to test.
		 * @param mock_request Optionally provide a mock Request object if
		 * headers need to be manipulated, or other request customizations are
		 * needed.
		 * @param config_override Optionally provide a HashMap containing config
		 * overrides for this request.
		 */
		public static TestResponse mock_dispatch_with_request( Application app, Request mock_request, HashMap<string,string>? config_override = null ) {
			Config.reset();
			var application_name = Ambition.Utility.get_application_name();
			var i = typeof(Engine.Test);
			if ( i > 0 ) {}
			string path = Environment.get_current_dir() + "/bin/" + application_name + "-bin";
			Dispatcher.set_default_config({path});
			Config.get_instance().parse_config();
			Config.set_value( "app.log_level", "error" );
			if ( config_override != null ) {
				foreach ( var key in config_override.keys ) {
					Config.set_value( key, config_override[key] );
				}
			}
			app.run( { path, "--engine", "Test" });
			State state = ( (Engine.Test) app.dispatcher.engine ).handle_request(mock_request);
			var response = new TestResponse();
			response.state = state;
			return response;
		}

	}
}