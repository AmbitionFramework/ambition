/*
 * Build.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2014 Sensical, Inc.
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
	 * Build engine.
	 */
	public class Build : Object {
		private static const int RESULT_SUCCESS = 0;
		private static const int RESULT_FAIL = -1;

		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.Build");
		internal string application_name;

		/**
		 * Target Ambition version.
		 */
		public string? target_version { get; set; }

		public Build() {
			var app_name = Ambition.Utility.get_application_name();
			if ( app_name == null ) {
				logger.error("Somehow, we are not in a project directory.");
			}
			application_name = app_name;
		}

		/**
		 * Read build config from path
		 */
		public bool parse_build_config( string file_path ) {
			File file = File.new_for_path(file_path);
			if ( !file.query_exists() ) {
				file = null;
			}

			if ( file == null ) {
				logger.error( "Build config '%s' is missing.".printf(file_path) );
				return false;
			}

			// Parse config file
			try {
				var input_stream = new DataInputStream( file.read() );
				string line;
				while ( ( line = input_stream.read_line(null) ) != null ) {
					parse_line(line);
				}
			} catch (Error e) {
				logger.error( "Error reading config \"%s\"".printf( file.get_path() ), e );
				return false;
			}

			return true;
		}

		public void parse_line( string line ) {
			// Skip potential comments
			if ( line.has_prefix("#") || line.has_prefix("//") || line.length == 0 ) {
				return;
			}
			string key = line.substring( 0, line.index_of("=") ).chomp().chug();
			string value = line.substring( line.index_of("=") + 1 ).chomp().chug();
			string gfield = key.replace( "_", "-" );
			ParamSpec p = this.get_class().find_property(gfield);
			if ( p != null ) {
				Value v = Value( typeof(string) );
				v.set_string(value);
				this.set_property( gfield, v );
			}
		}

		/**
		 * Build current project.
		 */
		internal int build() {
			if ( target_version == null ) {
				parse_build_config("config/build.conf");
			}
			var plugin = new Ambition.Utility.Plugin();
			if ( plugin.resolve_plugins() == false ) {
				return RESULT_FAIL;
			}
			if ( setup_build_directory() != RESULT_SUCCESS ) {
				return RESULT_FAIL;
			}
			if ( cmake_project() != RESULT_SUCCESS ) {
				return RESULT_FAIL;
			}
			if ( build_project() != RESULT_SUCCESS ) {
				return RESULT_FAIL;
			}
			return RESULT_SUCCESS;
		}

		/**
		 * Prepare/create build directory
		 */
		internal int setup_build_directory() {
			try {
				var build_directory = File.new_for_path("build");
				if ( ! build_directory.query_exists() ) {
					build_directory.make_directory();
				}
			} catch (Error e) {
				logger.error( "Unable to create or query build directory: %s".printf( e.message ) );
				return -1;
			}
			if ( Environment.set_current_dir("build") == -1 ) {
				logger.error( "Unable to change to build directory" );
				return -1;
			}
			return 0;
		}

		/**
		 * Run cmake on current application.
		 */
		internal int cmake_project() {
			string standard_output, standard_error;
			int exit_status;

			logger.info( "Running cmake..." );
			try {
				Process.spawn_command_line_sync(
					"cmake ..",
					out standard_output,
					out standard_error,
					out exit_status
				);
			} catch (SpawnError se) {
				logger.error( "Unable to run cmake: %s".printf( se.message ) );
				return_home();
				return -1;
			}
			if ( exit_status != 0 ) {
				logger.error( "Error building project files via cmake:\n%s".printf(standard_error) );
				return_home();
				return -1;
			}

			return 0;
		}

		/**
		 * Make the current application.
		 */
		internal int build_project() {
			string standard_output, standard_error;
			int exit_status;

			logger.info( "Building project..." );
			try {
				Process.spawn_command_line_sync(
					"make",
					out standard_output,
					out standard_error,
					out exit_status
				);
			} catch (SpawnError se) {
				logger.error( "Unable to run make: %s".printf( se.message ) );
				return_home();
				return -1;
			}
			if ( exit_status != 0 ) {
				logger.error( "Error building current application:\n%s".printf(standard_error) );
				return_home();
				return -1;
			}

			return 0;
		}

		private void return_home() {
			if ( Environment.get_current_dir().has_suffix("build") ) {
				Environment.set_current_dir("..");
			}
		}
	}
}