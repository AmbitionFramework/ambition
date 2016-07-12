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
	 * be as simple as "/", or more complex. The target is a string representing
	 * the namespace and method of the target block of code to execute. Each of
	 * the three requirements can also have multiple values. For example:
	 * An action can be made to respond to GET, POST, and PUT.
	 * An action can respond to both "/", and "/example".
	 * An action can start with "Main.check_eligibility" and then "Main.index".
	 */
	public class Action : Object {
		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.Action");
		private ArrayList<HttpMethod?> methods = new ArrayList<HttpMethod?>();
		private ArrayList<string> targets = new ArrayList<string>();
		private ArrayList<string> paths = new ArrayList<string>();
		private Marshaller? request_marshaller = null;
		private Marshaller? response_marshaller = null;

		/**
		 * Add an HTTP method to respond to
		 */
		public Action method( HttpMethod method ) {
			methods.add(method);
			return this;
		}

		/**
		 * Marshal response object from type to format
		 * @param content_type Content type to marshal
		 * @param object_type Object type to expect
		 * @param serializer Serializer to use to serialize
		 */
		public Action marshal_response( Type object_type, ISerializer serializer ) {
			request_marshaller = new Marshaller( serializer, object_type );
			return this;
		}

		/**
		 * Marshal request body from format to type
		 * @param content_type Content type to marshal
		 * @param serializer Serializer to use to deserialize
		 * @param object_type Object type to provide
		 */
		public Action marshal_request( ISerializer serializer, Type object_type ) {
			response_marshaller = new Marshaller( serializer, object_type );
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
			return this;
		}

		/**
		 * Add a target to this method.
		 *
		 * 
		 */
		public Action target( string target ) {
			// Should probably validate the target here instead of at compile
			targets.add(target);
			return this;
		}

		internal class Marshaller : Object {
			public ISerializer serializer { get; set; }
			public Type? obj_type { get; set; }

			public Marshaller( ISerializer serializer, Type obj_type ) {
				this.serializer = serializer;
				this.obj_type = obj_type;
			}
		}
	}
}