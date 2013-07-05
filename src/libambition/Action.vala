/*
 * Action.vala
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
namespace Ambition {
	/**
	 * Action definition.
	 */
	public class Action : Object {
		public ArrayList<HttpMethod?> methods { get; set; default = new ArrayList<HttpMethod?>(); }
		public ArrayList<ActionMethod?> targets { get; set; default = new ArrayList<ActionMethod?>(); }
		public string last_path { get { return this.targets.get( this.targets.size - 1 ).path; } }
		public Regex _regex;

		/**
		 * Set the path to respond to. Allows named captures (e.g. foo/{bar}/).
		 * @param path      Full path, adds leading / if not specified.
		 * @param with_args Boolean, set to true if you want captures after the path.
		 * @return Instance of this Action
		 */
		public Action path( string path, bool with_args = false ) {
			string escaped = path.replace( "/", "\\/" );
			if ( escaped.length > 2 && escaped.has_suffix("\\/") ) {
				escaped = escaped.substring( 0, escaped.length - 2 );
			}
			try {
				var re = new Regex( "^" + escaped + ( with_args ? "" : "$" ) );
				this.regex(re);
			} catch (RegexError e) {
				Logger.error( "Invalid regex from path: %s (%s)".printf( path, e.message ) );
			}

			return this;
		}

		/**
		 * Set the regex to respond to. Will override path().
		 * @param regex Regex object. Will not match leading /.
		 * @return Instance of this Action
		 */
		public Action regex( Regex regex ) {
			this._regex = regex;
			return this;
		}

		/**
		 * Adds an allowed HttpMethod to respond to. Defaults to HttpMethod.ALL.
		 * @param method HttpMethod
		 * @return Instance of this Action
		 * @see HttpMethod
		 */
		public Action allow_method( HttpMethod method ) {
			this.methods.add(method);
			return this;
		}

		/**
		 * Add target ActionMethodCall to this action's chain.
		 * @param am ActionMethodCall delegate.
		 * @return Instance of this Action
		 */
		public Action add_target( ActionMethodCall am ) {
			this.targets.add( new ActionMethod(am) );
			return this;
		}

		/**
		 * Add target ActionMethod to this action's chain.
		 * @param am ActionMethod instance.
		 * @return Instance of this Action
		 */
		public Action add_target_method( ActionMethod am ) {
			this.targets.add(am);
			return this;
		}

		/**
		 * Given a path and a method, return true if this action can respond to
		 * the request.
		 * @param decoded_path Dispatcher-decoded path
		 * @param method HttpMethod of given request
		 */
		public bool responds_to_request( string decoded_path, HttpMethod method, out MatchInfo info = null ) {
			Regex re = this._regex;
			if ( re.match( decoded_path, 0, out info ) ) {
				// Why ( method in this.methods ) doesn't work, I do not know.
				foreach ( var supported_method in this.methods ) {
					return ( supported_method == method );
				}
				
			}
			return false;
		}
	}
}