/*
 * Clean.vala
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

namespace Ambition.Utility {
	/**
	 * Clean the current application.
	 */
	public class Clean : Object {
		private string application_name { get; set; }
		public int run( string command ) {
			var app_name = get_application_name();
			if ( app_name == null ) {
				Logger.error("Somehow, we are not in a project directory.");
				return -1;
			}

			// Make (if necessary) and change to build directory
			var build_directory = File.new_for_path("build");
			if ( ! build_directory.query_exists() ) {
				Logger.info("No build directory to clean.");
				return 0;
			}
			if ( Environment.set_current_dir("build") == -1 ) {
				Logger.error( "Unable to change to build directory" );
				return 0;
			}

			switch (command) {
				case "clean":
					Logger.info( "Cleaning project..." );
					string standard_output, standard_error;
					int exit_status;
					try {
						Process.spawn_command_line_sync(
							"make clean",
							out standard_output,
							out standard_error,
							out exit_status
						);
					} catch (SpawnError se) {
						Logger.error( "Unable to run make clean: %s".printf( se.message ) );
						return -1;
					}
					if ( exit_status != 0 ) {
						Logger.error( "Error cleaning current application:\n%s".printf(standard_error) );
						return -1;
					}
					break;
			}

			if ( Environment.get_current_dir().has_suffix("build") ) {
				Environment.set_current_dir("..");
			}
			return 0;
		}
	}
}