/*
 * ControllerMethod.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2016 Sensical, Inc.
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
using Ambition.Serializer;
namespace Ambition {
	/**
	 * Delegate method for a controller method expecting a State and returning a
	 * Result.
	 */
	public delegate Result ControllerMethodStateResult( State state );

	/**
	 * Delegate method for a controller method expecting a State and a marshaled
	 * object and returning a Result.
	 */
	public delegate Result ControllerMethodObjectResult( State state, Object? o );

	/**
	 * Delegate method for a controller method expecting a State and a marshaled
	 * object and returning an Object.
	 */
	public delegate Object? ControllerMethodObjectObject( State state, Object? o );

	public class ControllerMethod : Object {
		public enum MethodType {
			CMSR,
			CMOR,
			CMOO
		}

		public MethodType controller_method_type;
		public ControllerMethodStateResult cmsr;
		public ControllerMethodObjectResult cmor;
		public ControllerMethodObjectObject cmoo;
		public Route route;

		public ControllerMethod.with_state_result( Route r, ControllerMethodStateResult m ) {
			this.controller_method_type = MethodType.CMSR;
			this.cmsr = m;
			this.route = r;
		}

		public ControllerMethod.with_object_result( Route r, ControllerMethodObjectResult m ) {
			this.controller_method_type = MethodType.CMOR;
			this.cmor = m;
			this.route = r;
		}

		public ControllerMethod.with_object_object( Route r, ControllerMethodObjectObject m ) {
			this.controller_method_type = MethodType.CMOO;
			this.cmoo = m;
			this.route = r;
		}

		public Result? execute( State state ) {
			switch(controller_method_type) {
				case MethodType.CMSR:
					return execute_cmsr(state);

				case MethodType.CMOR:
					return execute_cmor(state);

				case MethodType.CMOO:
					return execute_cmoo(state);
			}

			// If this is constructed normally, this won't happen. If it is not,
			// well.
			return null;
		}

		private Result? execute_cmsr( State state ) {
			return cmsr(state);
		}

		private Result? execute_cmor( State state ) {
			Object? o = get_object_from_state(state);
			return cmor( state, o );
		}

		private Result? execute_cmoo( State state ) {
			Object? o = get_object_from_state(state);
			Object? result = cmoo( state, o );
			string? serialized = determine_serialize( state, result );
			return new Ambition.CoreView.RawString(serialized);
		}

		public Object? get_object_from_state( State state ) {
			if ( state.request.request_body == null || state.request.request_body.length == 0 ) {
				return null;
			}

			var marshallers = route.request_marshallers;
			string[] types = state.request.content_type.split(";");
			types += "*";

			foreach ( var content_type in types ) {
				if ( marshallers.has_key(content_type) ) {
					Object? o = marshallers[content_type].serializer.deserialize(
						(string) state.request.request_body,
						marshallers[content_type].obj_type
					);
					return o;
				}
			}
			
			return null;
		}

		public string? determine_serialize( State state, Object o ) {
			var marshallers = route.response_marshallers;
			string? accept_type = null;
			var headers = state.request.headers;
			string? best_accept_type = null;
			if ( headers.has_key("Accept") ) {
				best_accept_type = parse_accept_header( headers["Accept"] );
			} else if ( headers.has_key("HTTP_ACCEPT") ) {
				best_accept_type = parse_accept_header( headers["HTTP_ACCEPT"] );
			} else {
				best_accept_type = parse_accept_header();
			}
			if ( best_accept_type != null ) {
				accept_type = best_accept_type;
			}
			string result = "";

			// If we found an accept_type, serialize and set content type, else
			// it is a bad request.
			if ( accept_type != null ) {
				result = marshallers[accept_type].serializer.serialize(o);
				state.response.content_type = accept_type;
			} else {
				var obj = (ErrorMessage) ResponseHelper.unsupported_media_type(state);
				result = obj.message;
			}
			return result;
		}

		/**
		 * Parse the Accept header, and choose the best media type based on
		 * available serializers.
		 * @param accept_header Original HTTP Accept header
		 */
		public string? parse_accept_header( string? accept_header = null ) {
			var accept_list = new ArrayList<string>();
			if ( accept_header != null ) {
				foreach ( var accept_dirty in accept_header.split(",") ) {
					var accept = accept_dirty.replace( " ", "" );
					string q = "1.0";
					if ( ";" in accept ) {
						string[] accept_pair = accept.split(";");
						accept = accept_pair[0];
						for ( int i = 1; i < accept_pair.length; i++ ) {
							string[] qualifier = accept_pair[i].split("=");
							if ( qualifier[0] == "q" ) {
								q = qualifier[1];
							}
						}
					}
					accept_list.add( "%s|%s".printf( q, accept ) );
				}
				// TODO: Holy crap, I hate this.
				// Sort by q, in reverse order
				accept_list.sort(
					(a, b) => {
						string[] a_array = a.split("|");
						string[] b_array = b.split("|");
						double aa = double.parse(a_array[0]);
						double bb = double.parse(b_array[0]);
						if ( aa == bb ) return 0;
						if ( aa > bb )  return -1;
						return 1;
					}
				);
				foreach ( var accept_combo_string in accept_list ) {
					string[] accept_combo = accept_combo_string.split("|");
					if ( route.response_marshallers.has_key( accept_combo[1] ) ) {
						return accept_combo[1];
					}
				}
			}
			if ( Config.lookup("default_accept_type") != null ) {
				return Config.lookup("default_accept_type");
			}

			return null;
		}
	}
}
