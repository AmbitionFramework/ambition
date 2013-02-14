/*
 * Run.vala
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
	 * Compile and run the current application.
	 * TODO: Ideally, this should wrap the existing engine type and be able
	 * to proxy the application inside. That way, if an error occurs, then
	 * the error can be output in dev mode, or captured and parsed in prod.
	 * This probably means that a compiled web application should be a library
	 * that can be dynamically loaded by Utility. oof.
	 */
	public class Run : Object {
		private string application_name { get; set; }
		internal static bool interrupted { get; set; default = false; }

		public int run( bool daemonize = false ) {
			var app_name = get_application_name();
			if ( app_name == null ) {
				Logger.error("Somehow, we are not in a project directory.");
				return -1;
			}
			application_name = app_name;
			build_and_run(daemonize);
			if ( Environment.get_current_dir().has_suffix("build") ) {
				Environment.set_current_dir("..");
			}
			return 0;
		}

		public int test() {
			var app_name = get_application_name();
			if ( app_name == null ) {
				Logger.error("Somehow, we are not in a project directory.");
				return -1;
			}
			application_name = app_name;
			run_tests();
			if ( Environment.get_current_dir().has_suffix("build") ) {
				Environment.set_current_dir("..");
			}
			return 0;
		}

		internal int run_tests() {
			int exit_status;

			var plugin = new Plugin();
			if ( plugin.resolve_plugins() == false ) {
				return -1;
			}
			if ( setup_build_directory() != 0 ) {
				return -1;
			}
			if ( cmake_project() != 0 ) {
				return -1;
			}
			if ( build_project() != 0 ) {
				return -1;
			}

			Logger.info( "Running tests..." );
			var cur_dir = Environment.get_current_dir();
			Environment.set_current_dir( cur_dir.substring( 0, cur_dir.length - 5 ) );
			string[] args = { "%s/build/test/test-application".printf( Environment.get_current_dir() ) };
			try {
				Process.spawn_sync(
					null,
					args,
					null,
					SpawnFlags.CHILD_INHERITS_STDIN,
					null,
					null,
					null,
					out exit_status
				);
			} catch (SpawnError wse) {
				Logger.error( "Unable to run tests: %s".printf( wse.message ) );
				return -1;
			}

			return 0;
		}

		/**
		 * Build and run current project.
		 */
		internal int build_and_run( bool daemonize = false ) {
			int exit_status;

			if (daemonize) {
				// Figure out where to store the log
				Config.set_value( "ambition.app_name", application_name );
				var log_file = Config.lookup_with_default( "app.log_file", "%s.application.log".printf(application_name) );
				
				// Redirect output, do not overwrite
				stdout = FileStream.open( log_file, "a+" );
				stderr = FileStream.open( log_file, "a+" );

				// Daemonize
				var pid = Posix.fork();
				if ( pid > 0 ) {
					return 0;
				}
			}

			var plugin = new Plugin();
			if ( plugin.resolve_plugins() == false ) {
				return -1;
			}
			if ( setup_build_directory() != 0 ) {
				return -1;
			}
			if ( cmake_project() != 0 ) {
				return -1;
			}
			if ( build_project() != 0 ) {
				return -1;
			}

			// Spawn webapp
			while ( interrupted == false ) {
				Logger.info( "Executing application..." );
				var cur_dir = Environment.get_current_dir();
				Environment.set_current_dir( cur_dir.substring( 0, cur_dir.length - 5 ) );
				string[] args = { "%s/build/src/%s-bin".printf( Environment.get_current_dir(), application_name ) };
				Posix.signal( Posix.SIGINT, ignore_signal );
				try {
					Process.spawn_sync(
						null,
						args,
						null,
						SpawnFlags.CHILD_INHERITS_STDIN,
						null,
						null,
						null,
						out exit_status
					);
				} catch (SpawnError wse) {
					Logger.error( "Unable to run web application: %s".printf( wse.message ) );
					Posix.signal( Posix.SIGINT, null );
					interrupted = false;
					return -1;
				}
				if ( interrupted == false ) {
					Logger.info( "Captured error (%d).".printf(exit_status) );
					parse_exit_status(exit_status);
				}
			}
			Posix.signal( Posix.SIGINT, null );
			interrupted = false;

			return 0;
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
				Logger.error( "Unable to create or query build directory: %s".printf( e.message ) );
				return -1;
			}
			if ( Environment.set_current_dir("build") == -1 ) {
				Logger.error( "Unable to change to build directory" );
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

			Logger.info( "Running cmake..." );
			try {
				Process.spawn_command_line_sync(
					"cmake ..",
					out standard_output,
					out standard_error,
					out exit_status
				);
			} catch (SpawnError se) {
				Logger.error( "Unable to run make: %s".printf( se.message ) );
				return_home();
				return -1;
			}
			if ( exit_status != 0 ) {
				Logger.error( "Error building project files via cmake:\n%s".printf(standard_error) );
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

			Logger.info( "Building project..." );
			try {
				Process.spawn_command_line_sync(
					"make",
					out standard_output,
					out standard_error,
					out exit_status
				);
			} catch (SpawnError se) {
				Logger.error( "Unable to run make: %s".printf( se.message ) );
				return_home();
				return -1;
			}
			if ( exit_status != 0 ) {
				Logger.error( "Error building current application:\n%s".printf(standard_error) );
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

		private void parse_exit_status( int exit_status ) {
			switch (exit_status) {
				case 11:
					// SIGSEGV
					string? gdb = Environment.find_program_in_path("gdb");
					if ( gdb != null ) {
						var file = File.new_for_path("core");
						if ( file.query_exists() ) {
							Logger.info("Able to run against core");
						}
					}
					break;
			}
		}
	}

	public static void ignore_signal( int signum ) {
		Run.interrupted = true;
		Logger.info("Application interrupted");
	}
}