/*
 * Config.vala
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
	 * Singleton class representing the application configuration.
	 */
	public class Config : Object {
		private static ConfigInstance _config = null;

		/**
		 * Look up a config element by key name
		 * @param key Key name
		 * @return string
		 */
		public static string? lookup( string key ) {
			return get_instance().lookup(key);
		}

		/**
		 * Look up a config element by key name, with a default value if the
		 * value is not found
		 * @param key Key name
		 * @param default_value Default value
		 * @return string
		 */
		public static string? lookup_with_default( string key, string default_value ) {
			return get_instance().lookup_with_default( key, default_value );
		}

		/**
		 * Set a config value.
		 * @param key Key name
		 * @param value Value
		 */
		public static void set_value( string key, string value ) {
			get_instance().config_hash[key] = value;
		}

		/**
		 * Look up a config element by key name, and convert it to an integer.
		 * @param key Key name
		 * @return int value of result, or null
		 */
		public static int? lookup_int( string key ) {
			var value = get_instance().lookup(key);
			if ( value != null ) {
				return int.parse(value);
			}
			return null;
		}

		/**
		 * Look up a config element by key name, and convert it to an int64.
		 * @param key Key name
		 * @return int64 value of result, or null
		 */
		public static int64? lookup_int64( string key ) {
			var value = get_instance().lookup(key);
			if ( value != null ) {
				return int64.parse(value);
			}
			return null;
		}

		/**
		 * Look up a config element by key name, and convert it to a bool.
		 * Valid 'true' values are 'true' of any capitalization, '1', 't', and
		 * 'yes'. All other values are false.
		 * @param key Key name
		 * @return bool value of result, or null
		 */
		public static bool? lookup_bool( string key ) {
			var value = get_instance().lookup(key);
			if ( value != null ) {
				string lower = value.down();
				if ( lower == "true" || lower == "1" || lower == "t" || lower == "yes" ) {
					return true;
				}
				return false;
			}
			return null;
		}

		public static ConfigInstance get_instance() {
			if ( _config == null ) {
				_config = new ConfigInstance();
			}

			return _config;
		}

		public static void reset() {
			_config = null;
		}

	}

	public class ConfigInstance : Object {
		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.ConfigInstance");
		public HashMap<string,string> config_hash = new HashMap<string,string>();

		public string? lookup( string key ) {
			check_config();
			return config_hash[key];
		}

		public string? lookup_with_default( string key, string default_value ) {
			string result = lookup(key);
			if ( result == null ) {
				return default_value;
			}
			return result;
		}

		private void check_config() {
			if ( this.config_hash.size == 0 || this.config_hash.size == 2 ) {
				parse_config();
			}
		}

		public void parse_config() {
			string app_name = this.config_hash["ambition.app_name"];

			// Find config file
			string file_path = Environment.get_variable( app_name.up() + "_CONFIG" );
			File file = null;
			if ( file_path != null ) {
				file = File.new_for_path(file_path);
				if ( !file.query_exists() ) {
					file = null;
				}
			}
			if ( file == null ) {
				string file_name = app_name.down() + ".conf";
				string[] paths = {
					"./config",
					"../config",
					"/usr/local/etc",
					"/usr/etc",
					"/etc",
					".",
					".."
				};
				foreach ( string path in paths ) {
					file = File.new_for_path( "%s/%s".printf( path, file_name ) );

					if ( file.query_exists() ) {
						break;
					}
					file = null;
				}
			}

			if ( file == null ) {
				logger.error( "Cannot find config file for '%s'.".printf(app_name) );
				return;
			}

			parse_config_file(file);
		}

		public void parse_config_file( File file ) {
			// Parse config file
			try {
				var input_stream = new DataInputStream( file.read() );
				string line;
				while ( ( line = input_stream.read_line(null) ) != null ) {
					// Skip potential comments
					if ( !line.has_prefix("#") && !line.has_prefix("//") && line.length > 0 ) {
						string key = line.substring( 0, line.index_of("=") ).chomp().chug();
						string value = line.substring( line.index_of("=") + 1 ).chomp().chug();
						config_hash.set( key, value );
					}
				}
			} catch (Error e) {
				logger.error( "Error reading config \"%s\"".printf( file.get_path() ), e );
			}
		}
	}
}
