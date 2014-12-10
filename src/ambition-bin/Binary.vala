/*
 * Binary.vala
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
using Ambition.Utility;
using Gee;

public static HashMap<string,IUtility> utilities;

public static int main( string[] args ) {
	// Cache args
	AmbitionBinary.args = args;

	// Init Log4Vala with local config, if available
	var log4vala_config = File.new_for_path("config/log4vala.conf");
	if ( log4vala_config.query_exists() ) {
		Log4Vala.init("config/log4vala.conf");
	} else {
		Log4Vala.init();
	}

	utilities = new HashMap<string,IUtility>();
	/*
	 * Load utility plugins, if available
	 */
	var plugin_dir = File.new_for_path("plugins");
	if ( plugin_dir.query_exists() ) {
		var utility_list = Ambition.Utility.UtilityLoader.load_utilities_from_directory("plugins");
		if ( utility_list != null ) {
			// init
			foreach ( var utility in utility_list ) {
				utility.register_utility();
				utilities[ utility.name.down() ] = utility;
			}
		}
	}

	if ( args[1] == null ) {
		return execute_command( false, null, null );
	}
	return execute_command( false, args[1], args[2:args.length] );
}

public static int execute_command( bool as_interactive, string? command, string[]? args ) {
	if ( command == null ) {
		if ( in_application() ) {
			command = "shell";
		}
	} else if ( command in utilities.keys ) {
		return utilities[command].receive_command(args);
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
			if (as_interactive) {
				return no_interactive();
			}
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
#if !WIN32
		case "monitor":
			var m = new Ambition.Utility.Monitor();
			if ( !in_application() ) {
				usage( "monitor", as_interactive );
				return 1;
			}
			return m.run();
#endif
		case "shell":
			if (as_interactive) {
				return no_interactive();
			}
			var m = new Shell();
			if ( !in_application() ) {
				usage( "shell", as_interactive );
				return 1;
			}
			return m.run();

		case "build":
			var m = new Ambition.Utility.Run();
			if ( !in_application() ) {
				usage( "build", as_interactive );
				return 1;
			}
			return m.run_build();

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
			return m.test(args);

#if !WIN32
		case "daemon":
			if (as_interactive) {
				return no_interactive();
			}
			var m = new Ambition.Utility.Run();
			if ( !in_application() ) {
				usage( "daemon", as_interactive );
				return 1;
			}
			return m.run( true, args );
#endif

		case "clean":
			var m = new Ambition.Utility.Clean();
			if ( !in_application() ) {
				usage( "clean", as_interactive );
				return 1;
			}
			return m.run(command);

		case "fullclean":
			var m = new Ambition.Utility.Clean();
			if ( !in_application() ) {
				usage( "fullclean", as_interactive );
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

		case "controller":
		case "model":
		case "view":
		case "form":
			var m = new Ambition.Utility.Creator();
			if ( !in_application() || args.length < 1 ) {
				usage( command, as_interactive );
				return 1;
			}
			return m.run( command, args[0] );

		case "help":
		default:
			usage( null, as_interactive );
			break;
	}
	return 0;
}

public static bool in_application() {
	var src_dir = File.new_for_path("src");
	var ambition = File.new_for_path("src/Application.vala");
	if ( src_dir.query_exists() && ambition.query_exists() ) {
		var application_file = File.new_for_path("src/Application.vala");

		try {
			var input_stream = new DataInputStream( application_file.read() );
			string line;
			MatchInfo info;
			while ( ( line = input_stream.read_line(null) ) != null ) {
				if ( /namespace ([^ ]+)/.match( line, 0, out info ) ) {
					Config.set_value( "ambition.app_name", info.fetch(1) );
				}
			}
		} catch (Error e) {
			Log4Vala.Logger.get_logger("Ambition.Binary").error( "Error trying to read Application.vala", e );
			return false;
		}
		Config.set_value( "ambition.app_path", Environment.get_current_dir() );

		return true;
	}
	return false;
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
	if ( method == null || method == "build" ) {
		stdout.printf("build\n");
		wrap(
			"Build the current application without executing. Must be run from "
			+ "an application directory.\n"
		);
	}
	if ( method == null || method == "run" ) {
		stdout.printf("run\n");
		wrap(
			"Build and run the current application within a protected "
			+ "environment. Must be run from an application directory.\n"
		);
	}
#if !WIN32
	if ( !as_interactive && method == null || method == "daemon" ) {
		stdout.printf("daemon <--pid PATH_TO_PID>\n");
		wrap(
			"As a background process, perform the same actions as 'run'."
			+ "Using the --pid flag, you may optionally specify a pid file.\n"
		);
	}
#endif
	if ( method == null || method == "clean" ) {
		stdout.printf("clean\n");
		wrap(
			"Clean the current application. Must be run from an application "
			+ "directory.\n"
		);
	}
	if ( method == null || method == "fullclean" ) {
		stdout.printf("fullclean\n");
		wrap(
			"Clean the current application and all build artifacts. Must be run "
			+ "from an application directory.\n"
		);
	}
	if ( method == null || method == "test" ) {
		stdout.printf("test\n");
		wrap(
			"Build run unit tests in the test directory.\n"
		);
	}
#if !WIN32
	if ( method == null || method == "monitor" ) {
		stdout.printf("monitor\n");
		wrap(
			"Build and run the current application, and restart the "
			+ "application if a file is changed. Must be in the project "
			+ "directory to use this function. This will not currently "
			+ "work on Mac OS X/Darwin or Win32.\n"
		);
	}
#endif
	if ( method == null || method == "controller" ) {
		stdout.printf("controller <name>\n");
		wrap(
			"Create a new Controller class with the given name, and add to "
			+ "the build script.\n"
		);
	}
	if ( method == null || method == "model" ) {
		stdout.printf("model <name>\n");
		wrap(
			"Create a new Model class with the given name, and add to "
			+ "the build script.\n"
		);
	}
	if ( method == null || method == "view" ) {
		stdout.printf("view <name>\n");
		wrap(
			"Create a new View class with the given name, and add to "
			+ "the build script.\n"
		);
	}
	if ( method == null || method == "form" ) {
		stdout.printf("form <name>\n");
		wrap(
			"Create a new Form class with the given name, and add to "
			+ "the build script.\n"
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

	if ( utilities != null && utilities.size > 0 ) {

		if ( method == null ) {
			stdout.printf("Plugin Commands\n---------------\n\n");
		}

		if ( method == null || ( method != null && utilities.has_key(method) ) ) {
			foreach ( var utility_name in utilities.keys ) {
				stdout.printf( "%s\n", utilities[utility_name].help() );
			}
		} else if ( utilities != null && method in utilities.keys ) {
			stdout.printf( "%s\n", utilities[method].help() );
		}
	}
}

public static int no_interactive() {
	stdout.printf("This command is unavailable in the interactive shell.\n\n");
	return -1;
}

/**
 * Get current application name.
 */
public static string? get_application_name() {
	return Ambition.Utility.get_application_name();
}

/**
 * Soft wrap a string at a given column.
 * @param text Text to display and wrap
 * @param indent Default = 4, level of indentation for string
 */
public static void wrap( string text, int indent = 4 ) {
	Ambition.Utility.wrap( text, indent );
}

/**
 * Store global application data.
 */
public class AmbitionBinary : Object {
	public static string[] args = null;
}