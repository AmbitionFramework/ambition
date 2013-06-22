/*
 * IAuthorizer.vala
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
	 * Interface for building an authenticator.
	 */
	public interface IAuthorizer : Object {
		protected abstract HashMap<string,string> config { get; set; }

		/**
		 * Initialize authenticator
		 */
		public abstract void init( HashMap<string,string> config );

		/**
		 * Authenticate the current user given a username and password
		 * @param username Username
		 * @param password Password
		 * @param options Optional HashMap of additional options to pass to the 
		 *                authorizer or submodules.
		 * @return User object of authorized user or null
		 */
		public abstract IUser? authorize( string username, string password, HashMap<string,string>? options = null );

		/**
		 * Get a user object from a serialized string.
		 * @param serialized Serialized object data
		 * @return User object of authorized user or null
		 */
		public abstract IUser? get_user_from_serialized( string serialized );

		/**
		 * Retrieve a PasswordType from a string. If the type contains a ".",
		 * will try to construct a full type, otherwise, will look in the
		 * Ambition.Authorization.PasswordType namespace.
		 * @param password_type Password Type string
		 */
		protected IPasswordType? get_password_type_from_string( string password_type, string? namespace = null ) {
			if ( namespace == null ) {
				namespace = "";
			}
			string glib_type = null;
			if ( "." in password_type ) {
				glib_type = password_type.replace( ".", "" );
			} else {
 				glib_type = "AmbitionAuthorizationPasswordType%s".printf(password_type);
			}
			if ( App.password_types == null ) {
				App.password_types = new HashMap<string,IPasswordType>();
			}
			if ( App.password_types.has_key(namespace + glib_type) ) {
				return App.password_types[namespace + glib_type];
			} else {
				Type t = Type.from_name(glib_type);
				if ( t > 0 ) {
					App.password_types[namespace + glib_type] = (IPasswordType) Object.new(t);
					App.password_types[namespace + glib_type].init(config);
					return App.password_types[namespace + glib_type];
				}
			}
			return null;
		}

		/**
		 * Get an instance of the current authorizer's password type.
		 */
		public abstract IPasswordType? get_password_type_instance();
	}
}
