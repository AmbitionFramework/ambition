/*
 * ScaffoldManifest.vala
 * 
 * The Ambition Web Framework
 * http://www.ambitionframework.org
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

namespace Ambition.Utility {
	/**
	 * Container for a scaffold manifest.json file.
	 */
	public class ScaffoldManifest : Object {
		public int version { get; set; }
		public string name { get; set; }
		public string[]? config { get; set; }
		public string[]? creates { get; set; }
		public string[]? appends { get; set; }
		public string[]? deletes { get; set; }

		public string[]? pkgs { get; set; }
		public string[]? vapis { get; set; }
		public string[]? plugins { get; set; }

		/**
		 * Load a manifest.json file from an existing scaffold directory.
		 * @param scaffold_directory Existing scaffold directory.
		 * @return Instance of ScaffoldManifest or null.
		 */
		public static ScaffoldManifest? load_manifest( string scaffold_directory ) {
			var parser = new Json.Parser();
			try {
				if ( parser.load_from_file( "%s/manifest.json".printf(scaffold_directory) ) ) {
					return (ScaffoldManifest) Json.gobject_deserialize( typeof(ScaffoldManifest), parser.get_root() );
				}
			} catch ( Error e ) {
				Log4Vala.Logger.get_logger("Ambition.Utility.ScaffoldManifest").error( "Fatal: Unable to load manifest from '%s': %s".printf( scaffold_directory, e.message ) );
			}
			return null;
		}
	}
}
