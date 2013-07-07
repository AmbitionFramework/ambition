/*
 * LocalPluginService.vala
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
namespace Ambition.Plugin {
	/**
	 * Local plugin service.
	 */
	public class LocalPluginService : Object,IPluginService {
		public HashMap<string,string> config { get; set; }

		public File? retrieve_plugin( string plugin_name, string? version = null ) throws Error {
			var manifest = get_manifest(plugin_name);
			if ( manifest != null && manifest.directory != null ) {
				File dir = File.new_for_path( manifest.directory );
				if ( dir.query_exists() ) {
					return dir;
				}
			}
			return null;
		}

		public bool cleanup( File retrieved_plugin ) {
			// No cleanup required on local service.
			return true;
		}

		public ArrayList<PluginResult> search_plugin( string plugin_name ) throws Error {
			var available = available_plugins();
			var searched = new ArrayList<PluginResult>();
			foreach ( PluginResult av in available ) {
				if ( plugin_name.down() in av.name.down() || plugin_name.down() in av.description.down() ) {
					searched.add(av);
				}
			}
			return searched;
		}

		public ArrayList<PluginResult> available_plugins() throws Error {
			var results = new ArrayList<PluginResult>();
			var available = get_available_plugins( config["plugindir"] );
			if ( available != null ) {
				foreach ( PluginManifest plugin in available ) {
					results.add( new PluginResult( plugin.name, plugin.version, plugin.description ) );
				}
			}
			return results;
		}

		public ArrayList<PluginResult> check_outdated_plugin( HashMap<string,string> installed_plugins ) {
			var searched = new ArrayList<PluginResult>();
			try {
				var available = available_plugins();
				foreach ( PluginResult av in available ) {
					if ( installed_plugins[av.name] != null && av.version != installed_plugins[av.name]) {
						searched.add(av);
					}
				}
			} catch (Error e) {}
			return searched;
		}

		public PluginManifest? get_manifest( string plugin_name ) {
			var available = get_available_plugins( config["plugindir"] );
			foreach ( PluginManifest result in available ) {
				if ( result.name.down() == plugin_name.down() ) {
					return result;
				}
			}
			return null;
		}

		/**
		 * Attempt to find plugin directory. Returns null if not found.
		 */
		private File? find_plugin_directory( string? try_directory = null ) {
			string[] try_directories = {
				"/usr/local/share/ambition-framework",
				"/usr/share/ambition-framework",
				"~/.ambition-framework"
			};
			if ( try_directory != null ) {
				try_directories = { try_directory };
			}
			foreach ( string path in try_directories ) {
				var file = File.new_for_path( "%s/plugins".printf(path) );
				if ( file.query_exists() ) {
					return file;
				}
			}

			return null;
		}

		private ArrayList<PluginManifest>? get_available_plugins( string? try_plugin_directory = null ) {
			var plugin_directory = find_plugin_directory(try_plugin_directory);
			if ( plugin_directory != null ) {
				var plugins = new ArrayList<PluginManifest>();
				try {
					FileInfo file_info;
					var enumerator = plugin_directory.enumerate_children(
						FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, 0
					);

					while ( ( file_info = enumerator.next_file() ) != null ) {
						if ( file_info.get_file_type() == FileType.DIRECTORY ) {
							var manifest = PluginManifest.load_manifest( "%s/%s".printf( plugin_directory.get_path(), file_info.get_name() ) );
							if ( manifest != null ) {
								plugins.add(manifest);
							}
						}
					}
				} catch (Error e) {
					stderr.printf( "Error trying to get available plugins: %s\n", e.message );
				}
				return plugins;
			}
			return null;
		}

	}
}
