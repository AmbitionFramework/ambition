/*
 * Plugin.vala
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
using Ambition.Plugin;
namespace Ambition.Utility {

	/**
	 * Handle plugins for the current application.
	 */
	public class Plugin : Object {
		private string application_name { get; set; }

		public int run( string[] args ) {
			var app_name = get_application_name();
			if ( app_name == null ) {
				Logger.error("Somehow, we are not in a project directory.");
				return -1;
			}
			
			// Verify plugins directory exists
			try {
				var file = File.new_for_path("plugins");
				if ( !file.query_exists() ) {
					file.make_directory();
				}
			} catch (Error e) {
				Logger.error("Unable to create plugins directory.");
				return -1;
			}

			string plugin_command = args[0];
			switch (plugin_command) {
				case "add":
					install_plugin( args[1], args );
					break;
				case "remove":
					remove_plugin( args[1], args );
					break;
				case "info":
					info_plugin( args[1], args );
					break;
				case "search":
					search_plugin( args[1], args );
					break;
				case "outdated":
					check_outdated_plugin(args);
					break;
				case "installed":
					installed_plugin(args);
					break;
				default:
					Logger.error("Invalid plugin command '%s'.".printf(plugin_command) );
					return -1;
			}
			return 0;
		}

		public bool resolve_plugins() {
			Logger.info("Resolving dependencies...");
			string[] empty_args = {};
			var service = determine_plugin_service(empty_args);
			var configured = read_plugin_config();
			var to_install = new HashMap<string,string>();

			// Verify plugins directory exists
			try {
				var file = File.new_for_path("plugins");
				if ( !file.query_exists() ) {
					file.make_directory();
				}
			} catch (Error e) {
				Logger.error("Unable to create plugins directory.");
				return false;
			}

			// OS Type
			bool is_osx = false;
			foreach ( var v in Environment.list_variables() ) {
				if ( v.length > 6 && v.substring( 0, 6 ) == "Apple_" ) {
					is_osx = true;
					break;
				}
			}

			// Fill installed arraylist
			var installed = get_installed_manifests();
			if ( installed == null ) {
				return false;
			}

			// Verify installed plugins should be there and are the correct version
			foreach ( PluginManifest installed_plugin in installed ) {
				if ( configured[installed_plugin.name] != null && configured[installed_plugin.name] != installed_plugin.version ) {
					// Should be installed, but version mismatch
					remove_plugin_from_directory(installed_plugin.name);
					to_install[installed_plugin.name] = installed_plugin.version;
					installed.remove(installed_plugin);
				} else if ( configured[installed_plugin.name] == null ) {
					// Is installed, but shouldn't be
					remove_plugin_from_directory(installed_plugin.name);
					installed.remove(installed_plugin);
				}

				if (is_osx) {
					string library_path = Environment.get_variable("DYLD_LIBRARY_PATH");
					if ( library_path == null ) {
						library_path = "";
					} else {
						library_path = library_path + ":";
					}
					library_path = library_path + "plugins/" + installed_plugin.name;

					Environment.set_variable( "DYLD_LIBRARY_PATH", library_path, true );
				}
			}

			// Queue installation of any missing plugins
			foreach ( string plugin_name in configured.keys ) {
				bool exists = false;
				foreach ( PluginManifest installed_plugin in installed ) {
					if ( installed_plugin.name == plugin_name ) {
						exists = true;
						break;
					}
				}
				if ( exists == false ) {
					to_install[plugin_name] = configured[plugin_name];
				}
			}

			// Install any plugins that are queued
			foreach ( string plugin_name in to_install.keys ) {
				Logger.info( "Installing %s %s".printf( plugin_name, to_install[plugin_name] ) );

				try {
					File? temp_dir = service.retrieve_plugin(plugin_name);
					if ( temp_dir == null ) {
						Logger.error( "Unable to retrieve plugin." );
						return false;
					}
					add_plugin_to_directory( plugin_name, temp_dir );
				} catch (Error e) {
					return false;
				}
			}

			generate_plugins_cmake();

			return true;
		}

		public static HashMap<string,string> read_plugin_config() {
			var plugins = new HashMap<string,string>();
			try {
				var file = File.new_for_path("config/plugins.conf");

				if ( !file.query_exists() ) {
					stderr.printf( "Plugins config does not exist, assuming no plugins.\n" );
					return plugins;
				}

				var input_stream = new DataInputStream( file.read() );
				string line = null;
				while ( ( line = input_stream.read_line(null) ) != null ) {
					// Skip potential comments
					if ( !line.has_prefix("#") && !line.has_prefix("//") && "=" in line ) {
						string key = line.substring( 0, line.index_of("=") ).chomp().chug();
						string value = line.substring( line.index_of("=") + 1 ).chomp().chug();
						plugins[key] = value;
					}
				}
			} catch (Error e) {

			}
			return plugins;
		}

		public void write_plugin_config( HashMap<string,string> plugin_list ) {
			try {
				var file = File.new_for_path("config/plugins.conf");

				if ( file.query_exists() ) {
					file.delete();
				}
				var file_stream = new DataOutputStream( file.create( FileCreateFlags.NONE ) );

				file_stream.put_string("# This is a generated file. Edits to this file may not be preserved.\n\n");
				foreach ( string plugin_name in plugin_list.keys ) {
					file_stream.put_string( "%s=%s\n".printf( plugin_name, plugin_list[plugin_name] ) );
				}
			} catch (Error e) {
				stderr.printf( "%s\n", e.message );
			}
		}

		private void install_plugin( string plugin_name, string[] args ) {
			var service = determine_plugin_service(args);

			var manifest = service.get_manifest(plugin_name);
			if ( manifest == null ) {
				stderr.printf( "Plugin '%s' does not exist.\n", plugin_name );
				return;
			}

			stdout.printf( "Found %s %s.\n", manifest.name, manifest.version );

			// Get plugin from service
			File? temp_dir = null;
			try {
				temp_dir = service.retrieve_plugin(plugin_name);
				if ( temp_dir == null ) {
					stderr.printf( "Unable to retrieve plugin '%s'.\n", plugin_name );
					return;
				}
			} catch (Error e) {}

			// Remove existing plugin
			var installed = read_plugin_config();
			if ( installed[plugin_name] != null ) {
				stdout.printf( "Plugin '%s' is already installed, removing existing version.\n", plugin_name );
				remove_plugin( plugin_name, args );
			}

			// Install new plugin
			installed[plugin_name] = manifest.version;
			write_plugin_config(installed);

			add_plugin_to_directory( plugin_name, temp_dir );
			generate_plugins_cmake();

			stdout.printf( "Added plugin '%s' to project.\n", plugin_name );
		}

		private void remove_plugin( string plugin_name, string[] args ) {
			var installed = read_plugin_config();
			if ( ! installed.has_key(plugin_name) ) {
				stdout.printf( "Plugin '%s' is not installed.\n", plugin_name );
				return;
			}

			// Change config
			installed.unset(plugin_name);
			write_plugin_config(installed);

			// Remove plugin from plugins directory
			remove_plugin_from_directory(plugin_name);

			stdout.printf( "Removed plugin '%s' from project.\n", plugin_name );
		}

		private void check_outdated_plugin( string[] args ) {
			var service = determine_plugin_service(args);
			var installed = read_plugin_config();
			var plugins = service.check_outdated_plugin(installed);
			if ( plugins != null && plugins.size > 0 ) {
				foreach ( PluginResult plugin in plugins ) {
					stdout.printf( "%s (%s) %s\n", plugin.name, plugin.version, ( installed[plugin.name] != null ? "(Installed: " + installed[plugin.name] + ")" : "" ) );
					wrap( plugin.description );
				}
			} else {
				stdout.printf( "All plugins are up to date.\n" );
			}
		}

		private void info_plugin( string plugin_name, string[] args ) {
			var service = determine_plugin_service(args);
			var manifest = service.get_manifest(plugin_name);
			if ( manifest != null ) {
				stdout.printf( "Name: %s\n", manifest.name );
				stdout.printf( "Description:\n" );
				wrap( manifest.description );
				stdout.printf( "Latest version: %s\n", manifest.version );
				stdout.printf( "Author: %s\n", manifest.author );
				stdout.printf( "Required plugins:\n" );
				wrap( manifest.plugin_dependencies != null ? string.joinv( ", ", manifest.plugin_dependencies ) : "None" );
			} else {
				stdout.printf( "No plugin found.\n" );
			}
		}

		private void search_plugin( string plugin_name, string[] args ) {
			try {
				var service = determine_plugin_service(args);
				var installed = read_plugin_config();
				var plugins = service.search_plugin(plugin_name);
				if ( plugins != null && plugins.size > 0 ) {
					foreach ( PluginResult plugin in plugins ) {
						stdout.printf( "%s (%s) %s\n", plugin.name, plugin.version, ( installed[plugin.name] != null ? "(Installed: " + installed[plugin.name] + ")" : "" ) );
						wrap( plugin.description );
					}
				} else {
					stdout.printf( "No plugins found matching '%s'.\n", plugin_name );
				}
			} catch (Error e) {
				stderr.printf( "Unknown error searching plugins: %s", e.message );
			}
		}

		/**
		 * Report the currently installed plugins
		 */
		private void installed_plugin( string[] args ) {
			var installed = read_plugin_config();
			if ( installed != null && installed.size > 0 ) {
				foreach ( string plugin in installed.keys ) {
					stdout.printf( "%s (%s)\n", plugin, installed[plugin] );
				}
			} else {
				stdout.printf( "No plugins installed.\n" );
			}
		}

		/**
		 * Take a list of arguments and attempt to turn them into a config.
		 * @param args List of arguments from command line
		 */
		private HashMap<string,string> args_to_config( string[] args ) {
			var config = new HashMap<string,string>();
			string last_arg = "";
			foreach ( string? arg in args ) {
				if ( arg == null ) {
					break;
				}
				if ( arg.has_prefix("--") ) {
					last_arg = arg.substring(2);
					config[last_arg] = "";
				} else {
					config[last_arg] = arg;
				}
			}
			return config;
		}

		/**
		 * Based on project and arguments, determine the pluginservice to use
		 * and configure accordingly.
		 * @param args Command line arguments
		 */
		private IPluginService determine_plugin_service( string[] args ) {
			IPluginService service = null;
			var config = args_to_config(args);
			if ( config["remote"] != null ) {
				service = new HttpPluginService();
			} else {
				service = new LocalPluginService();
			}

			service.config = config;
			return service;
		}

		/**
		 * Add the given plugin and directory to the project.
		 * @param plugin_name Name of plugin
		 * @param temp_dir File object representing the temp directory of the plugin to copy
		 */
		private void add_plugin_to_directory( string plugin_name, File temp_dir ) {
			try {
				var destination_dir = File.new_for_path( "plugins/%s".printf(plugin_name) );
				if ( !destination_dir.query_exists() ) {
					destination_dir.make_directory();
				}

				var enumerator = temp_dir.enumerate_children(
					FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, 0
				);

				FileInfo file_info;
				while ( ( file_info = enumerator.next_file() ) != null ) {
					if ( file_info.get_file_type() != FileType.DIRECTORY ) {
						File to_copy = temp_dir.resolve_relative_path( file_info.get_name() );
						File dest = File.new_for_path( "%s/%s".printf( destination_dir.get_path(), file_info.get_name() ) );
						if ( file_info.get_name().has_suffix(".vapi") ) {
							// If this is a vapi, let's make sure the init_plugin() function doesn't exist.
							var re = /\[CCode \(cheader_filename = "ambition\-plugin\-[\w\.\d\-]+h"\)\]\npublic static GLib.Type init_plugin \(\);/s;
							uint8[] contents;
							string etag_out;
							to_copy.load_contents( null, out contents, out etag_out );
							string newcontent = re.replace( (string) contents, -1, 0, "" );
							dest.create( FileCreateFlags.REPLACE_DESTINATION ).write( newcontent.data );
						} else {
							to_copy.copy( dest, FileCopyFlags.NONE );
						}
					}
				}
			} catch (Error e) {
				stderr.printf( "Unable to copy file for plugin '%s': %s\n", plugin_name, e.message );
				return;
			}
		}

		/**
		 * Remove the given plugin directory from the project.
		 * @param plugin_name Name of plugin
		 */
		private void remove_plugin_from_directory( string plugin_name ) {
			try {
				var dir = File.new_for_path( "plugins/%s".printf(plugin_name) );

				if ( !dir.query_exists() ) {
					stderr.printf( "Plugin directory for '%s' does not exist.\n", plugin_name );
					return;
				}

				var enumerator = dir.enumerate_children(
					FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, 0
				);

				FileInfo file_info;
				while ( ( file_info = enumerator.next_file() ) != null ) {
					if ( file_info.get_file_type() != FileType.DIRECTORY ) {
						File sub_file = dir.resolve_relative_path( file_info.get_name() );
						sub_file.delete();
					}
				}
				dir.delete();
			} catch (Error e) {
				stderr.printf( "Unable to remove plugin directory for '%s': %s\n", plugin_name, e.message );
			}
		}

		private ArrayList<PluginManifest> get_installed_manifests() {
			var installed = new ArrayList<PluginManifest>();

			try {
				FileInfo file_info;
				File plugin_directory = File.new_for_path("plugins");
				var enumerator = plugin_directory.enumerate_children(
					FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, 0
				);

				while ( ( file_info = enumerator.next_file() ) != null ) {
					if ( file_info.get_file_type() == FileType.DIRECTORY ) {
						var manifest = PluginManifest.load_manifest( "%s/%s".printf( plugin_directory.get_path(), file_info.get_name() ) );
						if ( manifest != null ) {
							installed.add(manifest);
						}
					}
				}
			} catch (Error e) {
				Logger.error( "Error trying to get available plugins: %s".printf(e.message) );
				return installed;
			}

			return installed;
		}

		private void generate_plugins_cmake() {
			var manifests = get_installed_manifests();
			var pkgconfig = new HashSet<string>();
			var packages = new HashSet<string>();
			var dirs = new HashSet<string>();

			foreach ( var manifest in manifests ) {
				if ( manifest.require_link ) {
					if ( manifest.pkgconfig_dependencies != null && manifest.pkgconfig_dependencies.length > 0 ) {
						foreach ( var v in manifest.pkgconfig_dependencies ) {
							pkgconfig.add(v);
						}
					}
					if ( manifest.libraries != null && manifest.libraries.length > 0 ) {
						foreach ( var v in manifest.libraries ) {
							packages.add(v);
							dirs.add( "${CMAKE_SOURCE_DIR}/plugins/%s".printf(manifest.name) );
						}
					}
				}
			}

			string s_pkgconfig = "";
			string s_packages = "";
			string s_dirs = "";
			foreach ( var v in pkgconfig ) {
				s_pkgconfig = s_pkgconfig + v + "\n";
			}
			foreach ( var v in packages ) {
				s_packages = s_packages + v + "\n";
			}
			foreach ( var v in dirs ) {
				s_dirs = s_dirs + v + "\n";
			}

			string template = """# This file is used to determine linking for plugins.
# Do not edit this file, as it will be changed.

SET( APP_PLUGIN_PKGCONFIG
%s
)
SET( APP_PLUGIN_PACKAGES
%s
)
SET( APP_PLUGIN_LIBRARY_DIRS
%s
)

SET( APP_PLUGIN_VAPI_LIST )
FOREACH ( NEXT_ITEM ${APP_PLUGIN_LIBRARY_DIRS} )
	LIST( APPEND APP_PLUGIN_VAPI_LIST "--vapidir='${NEXT_ITEM}'" )
ENDFOREACH()

SET( APP_PLUGIN_INCLUDE_LIST )
FOREACH ( NEXT_ITEM ${APP_PLUGIN_LIBRARY_DIRS} )
	LIST( APPEND APP_PLUGIN_INCLUDE_LIST "-I'${NEXT_ITEM}'" )
ENDFOREACH()
""";

			try {
				var file = File.new_for_path("plugins/plugins.cmake");

				if ( file.query_exists() ) {
					file.delete();
				}
				var file_stream = new DataOutputStream( file.create( FileCreateFlags.NONE ) );

				file_stream.put_string( template.printf( s_pkgconfig, s_packages, s_dirs ) );
			} catch (Error e) {
				stderr.printf( "%s\n", e.message );
			}
		}
	}
}
