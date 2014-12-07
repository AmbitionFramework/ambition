/*
 * PluginManifest.vala
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

namespace Ambition.Plugin {
	/**
	 * Container for a Plugin manifest.json file.
	 */
	public class PluginManifest : Object {
		public string directory { get; set; }

		public string? name { get; set; }
		public string? version { get; set; }
		public string? author { get; set; }
		public string? url { get; set; }
		public string? description { get; set; }
		public string? documentation { get; set; }
		public bool require_link { get; set; }
		public string[]? libraries { get; set; }
		public string[]? pkgconfig_dependencies { get; set; }
		public string[]? plugin_dependencies { get; set; }
		public string[]? versions { get; set; }
		public string? minimum_target_version { get; set; }
		public string? maximum_target_version { get; set; }

		/**
		 * Load a manifest.json file from an existing plugin directory.
		 * @param plugin_directory Existing plugin directory.
		 * @return Instance of PluginManifest or null.
		 */
		public static PluginManifest? load_manifest( string plugin_directory ) {
			var parser = new Json.Parser();
			try {
				if ( parser.load_from_file( "%s/manifest.json".printf(plugin_directory) ) ) {
					var manifest = (PluginManifest) Json.gobject_deserialize( typeof(PluginManifest), parser.get_root() );
					manifest.directory = plugin_directory;
					return manifest;
				}
			} catch ( Error e ) {
				Log4Vala.Logger.get_logger("Ambition.Plugin.PluginManifest").error( "Fatal: Unable to load manifest from '%s'".printf( plugin_directory ), e );
			}
			return null;
		}

		public bool check_version( string target_version ) {
			int min_version = Ambition.parse_version(minimum_target_version);
			int max_version = Ambition.parse_version(maximum_target_version);
			int tar_version = Ambition.parse_version(target_version);
			return ( tar_version >= min_version && tar_version <= max_version );
		}
	}
}