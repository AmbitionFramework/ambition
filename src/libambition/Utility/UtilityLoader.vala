/*
 * UtilityLoader.vala
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

using Ambition;
using Gee;
namespace Ambition.Utility {
 	/**
 	 * Load utility plugins from directory.
 	 */
	public class UtilityLoader : Object {

		private delegate Type InitUtilityFunction();

		/**
		 * Given a directory, load available utility pliugins and return a list
		 * of instantiated utilities.
		 * @param directory_path Path to directory
		 */
		public static ArrayList<IUtility?> load_utilities_from_directory( string directory_path ) {
			var plugins = new ArrayList<IUtility?>();

			FileInfo file_info;
			try {
				var directory = File.new_for_path(directory_path);
				if ( ! directory.query_exists() ) {
					Log4Vala.Logger.get_logger("Ambition.Utility.UtilityLoader").error( "The 'plugins' directory does not exist." );
					return plugins;
				}

				var enumerator = directory.enumerate_children(
					FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, 0
				);

				while ( ( file_info = enumerator.next_file() ) != null ) {
					if ( file_info.get_name().has_prefix(".") ) {
						continue;
					}

					if ( file_info.get_file_type() == FileType.DIRECTORY ) {
						plugins.add_all( load_utilities_from_directory( directory_path + "/" + file_info.get_name() ) );
					} else if ( file_info.get_name().has_suffix(".so") || file_info.get_name().has_suffix(".dylib") ) {
						var plugin = load_plugin( directory_path, file_info.get_name() );
						if ( plugin != null ) {
							plugins.add(plugin);
						}
					}
				}
			} catch (Error e) {
				Log4Vala.Logger.get_logger("Ambition.Utility.UtilityLoader").error( "Unable to enumerate plugins directory", e );
				return plugins;
			}

			return plugins;
		}

		/**
		 * Given a directory and filename, load a plugin and return an IUtility
		 * instance, or null if invalid.
		 * @param directory_path Path to plugin directory
		 * @param filename Filename of module
		 */
		public static IUtility? load_plugin( string directory_path, string filename ) {
			Module module = Module.open( "%s/%s".printf( directory_path, filename), ModuleFlags.LOCAL );
			if ( module == null ) {
				Log4Vala.Logger.get_logger("Ambition.Utility.UtilityLoader").error( "Unable to load utility '%s': %s. Skipping.".printf( filename, Module.error() ) );
				return null;
			}
			void* register_function;
			if ( ! module.symbol( "init_utility", out register_function ) ) {
				return null;
			}

			unowned InitUtilityFunction init_plugin = (InitUtilityFunction) register_function;
			assert( init_plugin != null );
			module.make_resident();
			Type t = init_plugin();
			return (IUtility) Object.new(t);
		}

	}
}
