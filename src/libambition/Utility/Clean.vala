/*
 * Clean.vala
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

using Gee;

namespace Ambition.Utility {
	/**
	 * Clean the current application.
	 */
	public class Clean : Object {
		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.Utility.Clean");

		public int run( string command ) {
			var app_name = get_application_name();
			if ( app_name == null ) {
				logger.error("Somehow, we are not in a project directory.");
				return -1;
			}

			// Make (if necessary) and change to build directory
			var build_directory = File.new_for_path("build");
			if ( ! build_directory.query_exists() ) {
				logger.info("No build directory to clean.");
				return 0;
			}
			if ( Environment.set_current_dir("build") == -1 ) {
				logger.error( "Unable to change to build directory" );
				return 0;
			}

			switch (command) {
				case "clean":
					int result = do_clean();
					if ( result > 0 ) {
						return result;
					}
					break;
				case "fullclean":
					int result = full_clean();
					if ( result > 0 ) {
						return result;
					}
					break;
			}

			if ( Environment.get_current_dir().has_suffix("build") ) {
				Environment.set_current_dir("..");
			}
			return 0;
		}

		public int do_clean() {
			logger.info( "Cleaning project..." );
			string standard_output, standard_error;
			int exit_status;
			try {
				Process.spawn_command_line_sync(
					"ninja clean",
					out standard_output,
					out standard_error,
					out exit_status
				);
			} catch (SpawnError se) {
				logger.error( "Unable to run ninja clean", se );
				return -1;
			}
			if ( exit_status != 0 ) {
				logger.error( "Error cleaning current application:\n%s".printf(standard_error) );
				return -1;
			}
			return 0;
		}

		public int full_clean() {
			logger.info( "Full cleaning..." );
			string standard_output, standard_error;
			int exit_status;
			try {
				Process.spawn_command_line_sync(
					"rm -rf src test build.ninja meson-*",
					out standard_output,
					out standard_error,
					out exit_status
				);
			} catch (SpawnError se) {
				logger.error( "Unable to run", se );
				return -1;
			}
			if ( exit_status != 0 ) {
				logger.error( "Error cleaning current application:\n%s".printf(standard_error) );
				return -1;
			}

			return 0;
		}
	}
}
