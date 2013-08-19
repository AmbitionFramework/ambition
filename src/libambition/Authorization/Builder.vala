/*
 * Builder.vala
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
using Ambition;
namespace Ambition.Authorization {
	/**
	 * Build authenticators.
	 */
	public class Builder : Object {

		public static void build_authorizers() {

			// Initialize known Authorizer and PasswordType types
			var z = typeof( Authorizer.Htpasswd );
			z = typeof( Authorizer.Flat );
			z = typeof( PasswordType.SHA1 );
			z = typeof( PasswordType.SHA256 );
			z = typeof( PasswordType.MD5 );
			if ( z == 0 ) {}

			// Parse config to get auth names and their associated params
			var config = Config.get_instance();
			var config_breakdown = new HashMap<string,HashMap<string,string>>();
			foreach ( string key in config.config_hash.keys ) {
				if ( key.has_prefix("authorization") ) {
					string auth_name = key.substring( 14, key.index_of( ".", 14 ) - 14 );
					string auth_param = key.substring( key.index_of( ".", 14 ) + 1 );
					if ( ! config_breakdown.has_key(auth_name) ) {
						config_breakdown.set( auth_name, new HashMap<string,string>() );
					}
					config_breakdown[auth_name][auth_param] = config.config_hash[key];
				}
			}

			// Given that generated config, create authorizers
			App.authorizers = new HashMap<string,IAuthorizer>();
			foreach ( string auth_name in config_breakdown.keys ) {
				var params = config_breakdown.get(auth_name);
				var type = params.get("type");
				if ( type == null ) {
					Logger.warn( "Authorization '%s' has a missing type.".printf(auth_name) );
				} else {
					params["auth_name"] = auth_name;
					var authorizer = build_from_string( type, params );
					if ( authorizer == null ) {
						Logger.warn( "Could not find authorization type '%s' for '%s'.".printf( type, auth_name ) );
					} else {
						App.authorizers.set( auth_name, authorizer );
					}
				}
			}
		}

		private static IAuthorizer? build_from_string( string authorization_type, HashMap<string,string> config ) {
			IAuthorizer authorizer = null;
			string glib_type = "AmbitionAuthorizationAuthorizer%s".printf(authorization_type);
			Type t = Type.from_name(glib_type);
			if ( t > 0 ) {
				authorizer = (IAuthorizer) Object.new(t);
			} else {
				return null;
			}

			if ( authorizer != null ) {
				authorizer.init(config);
				return authorizer;
			}

			Logger.error( "Unable to initialize authorizer: %s", authorization_type );
			return null;
		}
	}
}
