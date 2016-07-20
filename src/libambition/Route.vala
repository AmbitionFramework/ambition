/*
 * Route.vala
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
	 * Represents a route (formerly an Action), linking an incoming HTTP request
	 * with code.
	 * 
	 * Routes determine how requests are processed through the application. At
	 * the core, a route must have an HTTP method, a path, and a target. The
	 * method can be any available HttpMethod. The path can be as simple as "/",
	 * or more complex. The target can be one of three different delegate types
	 * representing a controller method. Each of the three requirements can also
	 * have multiple values.
	 * 
	 * For example:
	 * A route can be made to respond to GET, POST, and PUT.
	 * A route can respond to both "/", and "/example".
	 * A route can start with "Main.check_eligibility" and then "Main.index".
	 *
	 * Targets are executed in the order they are supplied, no matter what
	 * method type they are.
	 */
	public class Route : Object {
		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.Route");
		public ArrayList<HttpMethod?> methods = new ArrayList<HttpMethod?>();
		public ArrayList<ControllerMethod> targets = new ArrayList<ControllerMethod>();
		public ArrayList<string> paths = new ArrayList<string>();
		public HashMap<string,Marshaller?> request_marshallers = new HashMap<string,Marshaller?>();
		public HashMap<string,Marshaller?> response_marshallers = new HashMap<string,Marshaller?>();
		public ArrayList<Regex?> _regexes = new ArrayList<Regex?>();

		/**
		 * Add an HTTP method to respond to
		 */
		public Route method( HttpMethod method ) {
			methods.add(method);
			return this;
		}

		/**
		 * Add a target that accepts a State and returns a Result.
		 * The method will look like:
		 * public static Result example_method( State state ) {}
		 */
		public Route target( ControllerMethodStateResult method ) {
			targets.add( new ControllerMethod.with_state_result( this, method ) );
			return this;
		}

		/**
		 * Add a target that accepts a State and an Object and returns a Result.
		 * The method will look like:
		 * public static Result example_method( State state, Object? o ) {}
		 */
		public Route target_object_result( ControllerMethodObjectResult method ) {
			targets.add( new ControllerMethod.with_object_result( this, method ) );
			return this;
		}

		/**
		 * Add a target that accepts a State and returns a Result.
		 * The method will look like:
		 * public static Object? example_method( State state ) {}
		 */
		public Route target_object( ControllerMethodStateObject method ) {
			targets.add( new ControllerMethod.with_state_object( this, method ) );
			return this;
		}

		/**
		 * Add a target that accepts a State and an Object and returns an
		 * Object.
		 * The method will look like:
		 * public static Object? example_method( State state, Object? o ) {}
		 */
		public Route target_object_object( ControllerMethodObjectObject method ) {
			targets.add( new ControllerMethod.with_object_object( this, method ) );
			return this;
		}

		/**
		 * HTTP path to respond to.
		 *
		 * A path will always start with /, and will be parsed almost literally.
		 * 
		 * You may add named captures by surrounding them with brackets. For
		 * example, /foo/bar/[page] will match /foo/bar/ and then send the value
		 * after the URL as a named capture called "page" in state.
		 * 
		 * Ending a URL with * will capture the rest of the URL as arguments,
		 * for example, /foo/bar/*.
		 *
		 * @param path String representation of the HTTP path
		 */
		public Route path( string path ) {
			// Should probably validate the path here instead of at compile
			paths.add(path);

			var re_named = /\[([^\]]+)\]/;
			string new_path;
			try {
				new_path = re_named.replace( path, -1, 0, "(?<\\1>.+?)" );
			} catch (RegexError e) {
				logger.error( "Unable to create matches from placeholders in path '" + path + "'.", e );
				return this;
			}
			var regex = "^" + new_path.replace( "/", "\\/" );
			if ( regex.has_suffix("*") ) {
				regex = regex.substring( 0, regex.length - 1 ) + ".*";
			} else if ( ! regex.has_suffix("/") ) {
				regex = regex + "\\/?";
			}
			regex = regex + "$";
			try {
				_regexes.add( new Regex(regex) );
			} catch (RegexError e) {
				logger.error( "Unable to create regex '" + regex + "'.", e );
				return this;
			}

			return this;
		}

		/**
		 * Marshal request body from format to type
		 * @param content_type Content type to marshal
		 * @param serializer Serializer to use to deserialize
		 * @param object_type Object type to provide
		 */
		public Route marshal_request( string content_type, ISerializer serializer, Type object_type ) {
			request_marshallers[content_type] = new Marshaller( serializer, object_type );
			return this;
		}

		/**
		 * Marshal response object from type to format
		 * @param content_type Content type to marshal
		 * @param object_type Object type to expect
		 * @param serializer Serializer to use to serialize
		 */
		public Route marshal_response( string content_type, ISerializer serializer ) {
			response_marshallers[content_type] = new Marshaller( serializer, null );
			return this;
		}

		/**
		 * Set up request and response marshallers to provide JSON for the
		 * application/json and text/json content types on the given object
		 * type.
		 */
		public Route marshal_json( Type object_type ) {
			var json = new Serializer.JSON();
			request_marshallers["application/json"] = new Marshaller( json, object_type );
			request_marshallers["text/json"] = request_marshallers["application/json"];
			response_marshallers["application/json"] = new Marshaller( json, null );
			response_marshallers["text/json"] = response_marshallers["application/json"];
			return this;
		}

		/**
		 * Given a path and a method, return true if this Route can respond to
		 * the request.
		 * @param decoded_path Dispatcher-decoded path
		 * @param method HttpMethod of given request
		 * @param info MatchInfo output variable for matches
		 * @param found Regex output variable for the found regex
		 */
		public bool responds_to_request( string decoded_path, HttpMethod method, out MatchInfo info = null, out Regex found = null ) {
			foreach ( var re in _regexes ) {
				if ( re.match( decoded_path, 0, out info ) ) {
					foreach ( var supported_method in this.methods ) {
						if ( supported_method == method || supported_method == HttpMethod.ALL ) {
							found = re;
							return true;
						}
					}
					
				}
			}
			return false;
		}

		/**
		 * Return string describing the current Route, suitable for output on
		 * application startup or debugging.
		 */
		public string route_info() {
			var output = new StringBuilder();

			var method_strings = new ArrayList<string>();
			methods.map<string>( v => { return v.to_string(); } ).@foreach( method => {
				method_strings.add(method);
				return true;
			});

			foreach ( var path in paths ) {
				output.append(
					"%30s %s --> %d target%s".printf(
						arraylist_joinv( ", ", method_strings ),
						path,
						targets.size,
						( targets.size == 1 ? "" : "s" )
					)
				);
			}

			return output.str;
		}

		public class Marshaller : Object {
			public ISerializer serializer { get; set; }
			public Type? obj_type { get; set; }

			public Marshaller( ISerializer serializer, Type? obj_type ) {
				this.serializer = serializer;
				this.obj_type = obj_type;
			}
		}
	}
}