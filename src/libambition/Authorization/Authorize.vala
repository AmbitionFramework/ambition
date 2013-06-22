/*
 * Authorize.vala
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
namespace Ambition.Authorization {
	/**
	 * Provides authorization functions to a state object.
	 */
	public class Authorize : Object {
		public IUser user { get; private set; }

		/**
		 * Attempt to authorize a user with the given authorizer.
		 * @param authorizer_name Authorizer name as defined by the application
		 *                        configuration.
		 * @param username Username
		 * @param password Plain-text password
		 * @return true if authorization successful
		 */
		public bool authorize( string authorizer_name, string username, string password, HashMap<string,string>? options = null ) {
			var authorizer = App.authorizers.get(authorizer_name);
			if ( authorizer == null ) {
				Logger.warn( "No such authorizer: %s".printf(authorizer_name) );
				return false;
			}
			IUser user = authorizer.authorize( username, password, options );
			if ( user != null ) {
				user.authorizer_name = authorizer_name;
				this.user = user;
				return true;
			}
			return false;
		}

		/**
		 * Unauthorize a user, or log out.
		 */
		public void unauthorize() {
			this.user = null;
		}

		/**
		 * Reauthorize a previously serialized authorization, for use with
		 * sessions.
		 * @param authorizer_name Authorizer name as defined by the application
		 *                        configuration
		 * @param serialized Serialized authorization
		 */
		public bool authorize_previous( string authorizer_name, string serialized ) {
			var authorizer = App.authorizers.get(authorizer_name);
			if ( authorizer == null ) {
				Logger.warn( "No such authorizer: %s".printf(authorizer_name) );
				return false;
			}
			IUser user = authorizer.get_user_from_serialized(serialized);
			if ( user != null ) {
				user.authorizer_name = authorizer_name;
				this.user = user;
				return true;
			}
			return false;
		}

		/**
		 * Encode a password using the given authorization type.
		 * @param authorizer_name Authorizer name as defined by the application
		 *                        configuration
		 * @param password Password to encode
		 * @param options Optional overrides to pass to convert()
		 */
		public string? encode_password( string authorizer_name, string password, HashMap<string,string>? options = null ) {
			var authorizer = App.authorizers.get(authorizer_name);
			if ( authorizer == null ) {
				Logger.warn( "No such authorizer: %s".printf(authorizer_name) );
				return null;
			}

			var p_type = authorizer.get_password_type_instance();
			if ( p_type == null ) {
				Logger.warn("Authorizer does not support external password types.");
				return null;
			}
			return p_type.convert( password, options );
		}
	}
}
