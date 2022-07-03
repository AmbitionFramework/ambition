/*
 * Run.vala
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
	 * Compile and run the current application.
	 * TODO: Ideally, this should wrap the existing engine type and be able
	 * to proxy the application inside. That way, if an error occurs, then
	 * the error can be output in dev mode, or captured and parsed in prod.
	 * This probably means that a compiled web application should be a library
	 * that can be dynamically loaded by Utility. oof.
	 */
	public class Run : Object {
		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.Utility.Run");
		private string application_name;
		private Build build;
		internal static bool interrupted { get; set; default = false; }

		construct {
			build = new Build();
		}

		public int run( bool daemonize = false, string[]? new_args = null ) {
			application_name = build.application_name;
			build_and_run( daemonize, new_args );
			if ( Environment.get_current_dir().has_suffix("build") ) {
				Environment.set_current_dir("..");
			}
			return 0;
		}

		public int run_build() {
			application_name = build.application_name;
			build.build();
			if ( Environment.get_current_dir().has_suffix("build") ) {
				Environment.set_current_dir("..");
			}
			return 0;
		}

		public int test( string[] args ) {
			application_name = build.application_name;
			run_tests(args);
			if ( Environment.get_current_dir().has_suffix("build") ) {
				Environment.set_current_dir("..");
			}
			return 0;
		}

		internal int run_tests( string[] args ) {
			int exit_status;

			int result = build.build();
			if ( result != 0 ) {
				return result;
			}

			logger.info( "Running tests..." );
			var cur_dir = Environment.get_current_dir();
			Environment.set_current_dir( cur_dir.substring( 0, cur_dir.length - 5 ) );
			string[] exec_args = {};

			// Find gtester
			string? gtester = Environment.find_program_in_path("gtester");
			if ( gtester != null ) {
				exec_args += gtester;
				exec_args += "--verbose";

				// Append args if given
				if ( args != null && args.length > 0 ) {
					foreach ( var arg in args ) {
						exec_args += arg;
					}
				}
			}

			// Add test binary
			exec_args += "%s/build/test/test-application".printf( Environment.get_current_dir() );

			try {
				Process.spawn_sync(
					null,
					exec_args,
					null,
					SpawnFlags.CHILD_INHERITS_STDIN,
					null,
					null,
					null,
					out exit_status
				);
			} catch (SpawnError wse) {
				logger.error( "Unable to run tests: %s".printf( wse.message ) );
				return -1;
			}

			return 0;
		}

		/**
		 * Build and run current project.
		 */
		internal int build_and_run( bool daemonize = false, string[]? new_args = null ) {
			int exit_status;

#if !WIN32
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
					if ( new_args != null && new_args.length >= 2 ) {
						for ( var i = 0; i < new_args.length; i += 2 ) {
							if ( i + 1 >= new_args.length ) {
								break;
							}
							string flag = new_args[i];
							string value = new_args[i + 1];
							if ( flag == "--pid" ) {
								try {
									var file = File.new_for_path(value);
									{
										FileOutputStream stream;
										if ( file.query_exists() ) {
											stream = file.replace( null, false, FileCreateFlags.NONE );
										} else {
											stream = file.create(FileCreateFlags.NONE);
										}
										if ( file.query_exists() ) {
											var data_stream = new DataOutputStream(stream);
											data_stream.put_string( "%ld".printf( (long) pid ) );
										} else {
											logger.error( "Unable to open pid file '%s' for writing".printf(value) );
										}
									}
								} catch (Error e) {
									logger.error( "Unable to write to pid file", e );
								}
							}
						}
					}
					return 0;
				}
			}
#endif

			int response = build.build();
			if ( response < 0 ) {
				return response;
			}

			// Spawn webapp
			while ( interrupted == false ) {
				logger.info( "Executing application..." );
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
					logger.error( "Unable to run web application: %s".printf( wse.message ) );
					Posix.signal( Posix.SIGINT, null );
					interrupted = false;
					return -1;
				}
				if ( interrupted == false ) {
					logger.info( "Captured error (%d).".printf(exit_status) );
					parse_exit_status(exit_status);
				}
			}
			Posix.signal( Posix.SIGINT, null );
			interrupted = false;

			return 0;
		}

		private void parse_exit_status( int exit_status ) {
			switch (exit_status) {
				case 11:
					// SIGSEGV
					string? gdb = Environment.find_program_in_path("gdb");
					if ( gdb != null ) {
						var file = File.new_for_path("core");
						if ( file.query_exists() ) {
							logger.info("Able to run against core");
						}
					}
					break;
			}
		}
	}

	public static void ignore_signal( int signum ) {
		Run.interrupted = true;
		Log4Vala.Logger.get_logger("Ambition.Utility.Run").info("Application interrupted");
	}
}
