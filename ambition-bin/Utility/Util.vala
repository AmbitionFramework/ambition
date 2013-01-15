/*
 * Util.vala
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

/*
 * This should compile to "ambition" which provides utilities to manage and
 * scaffold an Ambition application.
 */

using Ambition;
using Gee;

public static int main( string[] args ) {
	if ( args[1] == null ) {
		return Utility.execute_command( false, null, null );
	}
	return Utility.execute_command( false, args[1], args[2:args.length] );
}

namespace Ambition.Utility {
	public static int execute_command( bool as_interactive, string? command, string[]? args ) {
		if ( command == null ) {
			if ( in_application() ) {
				command = "shell";
			}
		}
		switch (command) {
			case "template-compile":
				var tc = new Ambition.TemplateCompiler();
				if ( args.length != 3 ) {
					usage( "template-compile", as_interactive );
					return 1;
				}
				tc.namespace = args[0];
				
				try {
					tc.compile_all( args[1], args[2] );
				} catch ( Ambition.TemplateCompileError e ) {
					stdout.printf( "Fatal Error compiling templates:\n\t%s\n", e.message );
					exit(2); // not zero
				}
				
				break;

			case "build-actions":
				var ab = new Ambition.ActionBuilder();
				if ( args.length != 3 ) {
					usage( "build-actions", as_interactive );
					return 1;
				}

				try {
					ab.run( args[0], args[1], args[2] );
				} catch ( Ambition.ActionBuilderError e ) {
					stdout.printf( "Fatal Error building actions:\n\t%s\n", e.message );
					exit(2); // not zero
				}
				
				break;

			case "new":
				var s = new Ambition.Utility.Scaffold();
				if ( args.length < 1 ) {
					usage( "new", as_interactive );
					return 1;
				}
				string[] profiles = null;
				if ( args.length > 1 ) {
					profiles = args[1:args.length];
				}
				return s.run( args[0], profiles );

			case "monitor":
				var m = new Ambition.Utility.Monitor();
				if ( !in_application() ) {
					usage( "monitor", as_interactive );
					return 1;
				}
				return m.run();

			case "shell":
				var m = new Ambition.Utility.Shell();
				if ( !in_application() ) {
					usage( "shell", as_interactive );
					return 1;
				}
				return m.run();

			case "run":
				var m = new Ambition.Utility.Run();
				if ( !in_application() ) {
					usage( "run", as_interactive );
					return 1;
				}
				return m.run();

			case "test":
				var m = new Ambition.Utility.Run();
				if ( !in_application() ) {
					usage( "test", as_interactive );
					return 1;
				}
				return m.test();

			case "daemon":
				var m = new Ambition.Utility.Run();
				if ( !in_application() ) {
					usage( "daemon", as_interactive );
					return 1;
				}
				return m.run(true);

			case "clean":
				var m = new Ambition.Utility.Clean();
				if ( !in_application() ) {
					usage( "clean", as_interactive );
					return 1;
				}
				return m.run(command);

			case "plugin":
				var m = new Ambition.Utility.Plugin();
				if ( !in_application() || args.length < 1 ) {
					usage( "plugin", as_interactive );
					return 1;
				}
				return m.run(args);

			case "dependencies":
				var m = new Ambition.Utility.Plugin();
				if ( !in_application() ) {
					usage( "dependencies", as_interactive );
					return 1;
				}
				return ( m.resolve_plugins() ? 0 : 1 );

			case "help":
			default:
				usage( null, as_interactive );
				break;
		}
		return 0;
	}

	public static bool in_application() {
		var src_dir = File.new_for_path("src");
		var ambition = File.new_for_path(".ambition");
		return ( src_dir.query_exists() && ambition.query_exists() );
	}

	public static void usage( string? method = null, bool as_interactive = false ) {
		if ( !as_interactive ) {
			stdout.printf("ambition utility\n");
			stdout.printf("Usage: ambition <command> <args>...\n\n");
		}

		if ( method == null ) {
			stdout.printf("Commands:\n\n");
		}

		if ( !as_interactive && ( method == null || method == "new" ) ) {
			stdout.printf("new <name> <profiles ...>\n");
			wrap(
				"Create and scaffold a new application. Provide a name for the "
				+ "application, and it will also be used as the default namespace "
				+ "for the new app. After the name, you may add additional "
				+ "profiles, which are added by plugins or optional features. By "
				+ "default, you may use 'cmake' for a CMake project.\n"
			);
		}
		if ( !as_interactive && (method == null || method == "shell" ) ) {
			stdout.printf("shell\n");
			wrap(
				"Launch the Ambition interactive shell. This will allow you to run "
				+ "commands from within an interactive environment.  Must be run "
				+ "from an application directory.\n"
			);
		}
		if ( method == null || method == "run" ) {
			stdout.printf("run\n");
			wrap(
				"Build and run the current application within a protected "
				+ "environment. Must be run from an application directory.\n"
			);
		}
		if ( method == null || method == "daemon" ) {
			stdout.printf("daemon\n");
			wrap(
				"As a background process, perform the same actions as 'run'.\n"
			);
		}
		if ( method == null || method == "clean" ) {
			stdout.printf("clean\n");
			wrap(
				"Clean the current application. Must be run from an application "
				+ "directory.\n"
			);
		}
		if ( method == null || method == "test" ) {
			stdout.printf("test\n");
			wrap(
				"Build run unit tests in the test directory.\n"
			);
		}
		if ( method == null || method == "monitor" ) {
			stdout.printf("monitor\n");
			wrap(
				"Build and run the current application, and restart the "
				+ "application if a file is changed. Must be in the project "
				+ "directory to use this function. This will not currently "
				+ "work on Mac OS X/Darwin or Win32.\n"
			);
		}
		if ( method == null || method == "plugin" ) {
			stdout.printf("plugin\n");
			wrap(
				"Manage plugins in the current application. Requires one of "
				+ "the following:"
			);
			string template_plugin = "        %-22s: %s\n";
			stdout.printf( template_plugin, "add <plugin> [version]", "Add a plugin, version is optional" );
			stdout.printf( template_plugin, "remove <plugin>", "Remove a plugin" );
			stdout.printf( template_plugin, "info <plugin>", "Get extended information about a plugin" );
			stdout.printf( template_plugin, "search <plugin>", "Search for a plugin" );
			stdout.printf( template_plugin, "outdated", "Show all outdated plugins" );
			stdout.printf( template_plugin, "installed", "Show all installed plugins" );

			wrap(
				"Using a version with 'add' will ignore the latest version of "
				+ "the application and always define the given version. Using "
				+ "'add' with a plugin that already exists will just replace "
				+ "the existing version with the given or latest version.\n"
			);
		}

		if ( method == null ) {
			stdout.printf("Internal/Advanced Commands\n--------------------------\n\n");
		}

		if ( method == null || method == "template-compile" ) {
			stdout.printf("template-compile <namespace> <input_directory> <output_directory>\n");
			wrap(
				"Should only be used within the makefile. Parses templates in "
				+ "the given input directory, creates corresponding vala "
				+ "classes, and then provides the files for building into the "
				+ "current project.\n"
			);
		}

		if ( method == null || method == "build-actions" ) {
			stdout.printf("build-actions <namespace> <input_directory> <output_directory>\n");
			wrap(
				"Should only be used within the makefile. Parses actions.conf "
				+ "in the given input directory, creates corresponding vala "
				+ "class.\n"
			);
		}

		if ( method == null || method == "dependencies" ) {
			stdout.printf("dependencies\n");
			wrap(
				"Parses actions.conf and resolves plugin dependencies.\n"
			);
		}
	}

	/**
	 * Get current application name.
	 */
	public static string? get_application_name() {
		var project_dir = File.new_for_path(".");
		if (
			!project_dir.query_exists()
			|| project_dir.query_file_type(FileQueryInfoFlags.NONE) != FileType.DIRECTORY
		) {
			Logger.error("Somehow, we are not in a project directory.");
			return null;
		}
		return project_dir.get_basename();
	}

	/**
	 * Soft wrap a string at a given column.
	 * @param text Text to display and wrap
	 * @param indent Default = 4, level of indentation for string
	 */
	public static void wrap( string text, int indent = 4 ) {
		int wrap_at = 80;
		var sb = new StringBuilder();
		foreach ( string word in text.split(" ") ) {
			if ( sb.len >= wrap_at || sb.len + word.length > wrap_at ) {
				stdout.printf( "%s\n", sb.str );
				sb = new StringBuilder();
			}
			if ( sb.len > 0 ) {
				sb.append(" ");
			} else {
				for ( int i = 0; i < indent; i++ ) {
					sb.append(" ");
				}
			}
			sb.append(word);
		}
		stdout.printf( "%s\n", sb.str );
	}
}
