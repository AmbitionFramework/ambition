/*
 * Action.vala
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
	 * Represents an action, linking an incoming HTTP request with code.
	 * 
	 * The actions configuration determines how requests are processed through
	 * the application. At the core, an action must have an HTTP method, a path,
	 * and a target. The method can be any available HttpMethod. The path can
	 * be as simple as "/", or more complex. The target can be one of three
	 * different delegate types representing a controller method. Each of
	 * the three requirements can also have multiple values.
	 * 
	 * For example:
	 * An action can be made to respond to GET, POST, and PUT.
	 * An action can respond to both "/", and "/example".
	 * An action can start with "Main.check_eligibility" and then "Main.index".
	 *
	 * Targets are executed in the order they are supplied, no matter what
	 * method type they are.
	 */
	public class Action : Object {
		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.Action");
		public ArrayList<HttpMethod?> methods = new ArrayList<HttpMethod?>();
		public ArrayList<ControllerMethod> targets = new ArrayList<ControllerMethod>();
		public ArrayList<string> paths = new ArrayList<string>();
		public Marshaller? request_marshaller = null;
		public Marshaller? response_marshaller = null;
		public ArrayList<Regex?> _regexes = new ArrayList<Regex?>();

		/**
		 * Add an HTTP method to respond to
		 */
		public Action method( HttpMethod method ) {
			methods.add(method);
			return this;
		}

		/**
		 * Add a target that accepts a State and returns a Result.
		 * The method will look like:
		 * public static Result example_method( State state ) {}
		 */
		public Action target( ControllerMethodStateResult method ) {
			targets.add( new ControllerMethod.with_state_result(method) );
			return this;
		}

		/**
		 * Add a target that accepts a State and an Object and returns a Result.
		 * The method will look like:
		 * public static Result example_method( State state, Object? o ) {}
		 */
		public Action target_object_result( ControllerMethodObjectResult method ) {
			targets.add( new ControllerMethod.with_object_result(method) );
			return this;
		}

		/**
		 * Add a target that accepts a State and an Object and returns an
		 * Object.
		 * The method will look like:
		 * public static Object? example_method( State state, Object? o ) {}
		 */
		public Action target_object_object( ControllerMethodObjectObject method ) {
			targets.add( new ControllerMethod.with_object_object(method) );
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
		public Action path( string path ) {
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
		public Action marshal_request( ISerializer serializer, Type object_type ) {
			request_marshaller = new Marshaller( serializer, object_type );
			return this;
		}

		/**
		 * Marshal response object from type to format
		 * @param content_type Content type to marshal
		 * @param object_type Object type to expect
		 * @param serializer Serializer to use to serialize
		 */
		public Action marshal_response( Type object_type, ISerializer serializer ) {
			response_marshaller = new Marshaller( serializer, object_type );
			return this;
		}

		/**
		 * Given a path and a method, return true if this action can respond to
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
						if ( supported_method == method ) {
							found = re;
							return true;
						}
					}
					
				}
			}
			return false;
		}

		/**
		 * Execute a given target with a given state, and return a result
		 * object.
		 */
		public Result execute_target( ControllerMethod wrapper, State state ) {
			return wrapper.execute(state);
		}

		/**
		 * Return string describing the current action, suitable for output on
		 * application startup or debugging.
		 */
		public string action_info() {
			var output = new StringBuilder();

			var method_strings = new ArrayList<string>();
			methods.map<string>( v => { return v.to_string(); } ).@foreach( method => {
				method_strings.add(method);
				return true;
			});

			foreach ( var path in paths ) {
				output.append(
					"%-30s %s --> %d targets".printf(
						arraylist_joinv( "", method_strings ),
						path,
						targets.size
					)
				);
			}

			return output.str;
		}

		public class Marshaller : Object {
			public ISerializer serializer { get; set; }
			public Type? obj_type { get; set; }

			public Marshaller( ISerializer serializer, Type obj_type ) {
				this.serializer = serializer;
				this.obj_type = obj_type;
			}
		}
	}
}