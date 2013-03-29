/*
 * AlmannaPlugin.vala
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

using Almanna;

public static Type init_plugin() {
	return typeof(Ambition.PluginSupport.AlmannaPlugin);
}

namespace Ambition.PluginSupport {
	/*
	 * Provide built-in support for the Almanna ORM, with entity registration
	 * and configuration via the application config file.
	 */
	public class AlmannaPlugin : Object,IPlugin {
		public string name { get { return "Almanna"; } }

		/*
		 * Start AlmannaPlugin with entity list.
		 * @param entities Array of Types representing entities.
		 */
		public AlmannaPlugin.with_entities( Type[] entities ) {
			this();
			foreach ( Type e in entities ) {
				Repo.add_entity(e);
			}
		}

		public void register_plugin() {
			// Register types for dynamic loading
			var type = typeof(Ambition.Authorization.Authorizer.Almanna);
			type = typeof(Ambition.Session.StorableAlmanna);
			type = typeof(Almanna.Loader);
			if ( type > 0 ) {}

			// Determine if connection data is in here
			string connection_string = Config.lookup("almanna.connection_string");
			if ( connection_string != null ) {
				string username = Config.lookup("almanna.username");
				string password = Config.lookup("almanna.password");
				string log_level = Config.lookup("almanna.log_level");
				string connections = Config.lookup("almanna.connections");
				var c = new Almanna.Config();
				c.connection_string = connection_string;
				c.username = username;
				c.password = password;
				if ( log_level != null ) {
					if ( log_level == "debug" ) {
						c.log_level = LogLevel.DEBUG;
					} else if ( log_level == "info" ) {
						c.log_level = LogLevel.INFO;
					} else if ( log_level == "error" ) {
						c.log_level = LogLevel.ERROR;
					}
				}
				if ( connections != null ) {
					c.connections = int.parse(connections);
				}

				try {
					Server.open(c);
				} catch ( Error e ) {
					Logger.error( "Almanna: Unable to open connection to server. (%s)".printf( e.message ) );
					return;
				}
				Logger.info( "Almanna: Connected to server." );
			}
		}
	}
}