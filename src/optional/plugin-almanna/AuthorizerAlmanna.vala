/*
 * AuthorizerAlmanna.vala
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
using Ambition.Authorization;
using Almanna;
namespace Ambition.Authorization.Authorizer {
	/**
	 * Authorize users using an Almanna entity. Requires additional config to
	 * work:
	 * * entity_type: mapping to the string representation of the GLib type of
	 * the entity. Example: ExampleApp.Model.DB.User would be
	 * ExampleAppModelDBUser.
	 * Optional config:
	 * * password_type: Type of password obfuscation/hashing in place. Defaults
	 * to a SHA1 PasswordType, but can be changed with password_type and that
	 * password type's associated configuration.
	 * * id_field: Defaults to first primary key property or "id"
	 * * username_field: Defaults to username
	 * * password_field: Defaults to password
	 */
	public class Almanna : Object,IAuthorizer {
		protected HashMap<string,string> config { get; set; }
		private string password_type { get; set; default = "SHA1"; }
		private string id_field { get; set; default = "id"; }
		private string username_field { get; set; default = "username"; }
		private string password_field { get; set; default = "password"; }

		public void init( HashMap<string,string> config ) {
			Logger.warn( "config is %s", ( config == null ? "null" : "not null") );
			this.config = config;
			if ( config["entity_type"] == null ) {
				Logger.warn("Missing entity_type for Almanna authorizer, this will fail");
				return;
			}
			string password_type = config.get("password_type");
			if ( password_type != null ) {
				this.password_type = password_type;
				config.unset("password_type");
			}
			string id_field = config.get("id_field");
			if ( id_field != null ) {
				this.id_field = id_field.replace( "_", "-" );
				config.unset("id_field");
			}
			string username_field = config.get("username_field");
			if ( username_field != null ) {
				this.username_field = username_field;
				config.unset("username_field");
			}
			string password_field = config.get("password_field");
			if ( password_field != null ) {
				this.password_field = password_field;
				config.unset("password_field");
			}
		}

		public IPasswordType? get_password_type_instance() {
			return get_password_type_from_string( password_type, config["auth_name"] );
		}

		public IUser? authorize( string username, string password, HashMap<string,string>? options = null ) {
			var p_type = get_password_type_instance();
			string entity_type = config["entity_type"];
			if ( "." in entity_type ) {
				entity_type = entity_type.replace( ".", "" );
			}
			Entity e = Repo.get_entity( Type.from_name(entity_type) );

			if ( e != null ) {
				try {
					var entity = e.search()
						.eq( username_field, username )
						.eq( password_field, p_type.convert( password, options ) )
						.single();
					if ( entity != null ) {
						Value v = Value( typeof(int) );
						entity.get_property( id_field, ref v );
						return new User.Almanna.with_params( config, v.get_int(), username );
					}
				} catch (SearchError se) {
					Logger.warn( "Caught Almanna SearchError: %s".printf( se.message ) );
					return null;
				}
			} else {
				Logger.error("Unable to find entity.");
			}
			return null;
		}

		public IUser? get_user_from_serialized( string serialized ) {
			var user = new User.Almanna.with_config(config);
			user.deserialize(serialized);
			if ( user.id > 0 ) {
				return user;
			}
			return null;
		}
	}
}
