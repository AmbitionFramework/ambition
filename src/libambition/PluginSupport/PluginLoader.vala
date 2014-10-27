/*
 * PluginLoader.vala
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
namespace Ambition.PluginSupport {
 	/**
 	 * Load plugins from plugin directory.
 	 */
	public class PluginLoader : Object {
		private static Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.PluginSupport.PluginLoader");
		private delegate Type InitPluginFunction();

		/**
		 * Given a directory, load available plugins and return a list of
		 * instantiated plugins.
		 * @param directory_path Path to plugin directory
		 */
		public static ArrayList<IPlugin?> load_plugins_from_directory( string directory_path ) {
			var plugins = new ArrayList<IPlugin?>();

			FileInfo file_info;
			try {
				var directory = File.new_for_path(directory_path);
				if ( ! directory.query_exists() ) {
					logger.error( "The 'plugins' directory does not exist." );
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
						plugins.add_all( load_plugins_from_directory( directory_path + "/" + file_info.get_name() ) );
					} else if ( file_info.get_name().has_suffix(".so") || file_info.get_name().has_suffix(".dylib") ) {
						var plugin = load_plugin( directory_path, file_info.get_name() );
						if ( plugin != null ) {
							plugins.add(plugin);
						}
					}
				}
			} catch (Error e) {
				logger.error( "Unable to enumerate plugins directory", e );
				return plugins;
			}

			return plugins;
		}

		/**
		 * Given a directory and filename, load a plugin and return an IPlugin
		 * instance, or null if invalid.
		 * @param directory_path Path to plugin directory
		 * @param filename Filename of module
		 */
		public static IPlugin? load_plugin( string directory_path, string filename ) {
			Module module = Module.open( "%s/%s".printf( directory_path, filename), ModuleFlags.BIND_LOCAL );
			if ( module == null ) {
				logger.error( "Unable to load plugin '%s': %s. Skipping.".printf( filename, Module.error() ) );
				return null;
			}
			void* register_function;
			if ( ! module.symbol( "init_plugin", out register_function ) ) {
				return null;
			}

			unowned InitPluginFunction init_plugin = (InitPluginFunction) register_function;
			assert( init_plugin != null );
			module.make_resident();
			Type t = init_plugin();
			return (IPlugin) Object.new(t);
		}

	}
}
