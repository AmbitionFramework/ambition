/*
 * Creator.vala
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
	 * Scaffold new controller/model/view/forms.
	 */
	public class Creator : Object {
		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.Utility.Creator");
		private string application_name;
		private string full_path;

		/**
		 * Entry point for Creator.
		 * @param type Class type to create
		 * @param name Class name
		 */
		public int run ( string type, string name ) {
			application_name = get_application_name();
			if ( application_name == null ) {
				logger.error("Somehow, we are not in a project directory.");
				return -1;
			}

			switch (type) {
				case "controller":
					return scaffold_controller(name);
				case "model":
					return scaffold_model(name);
				case "view":
					return scaffold_view(name);
				case "form":
					return scaffold_form(name);
				default:
					logger.error( "Cannot scaffold a '%s'.".printf(type) );
					return -1;
			}
		}

		/**
		 * Scaffold a Controller class.
		 * @param name Class name
		 */
		private int scaffold_controller( string name ) {
			string scaffold = """using Ambition;
using %s.View;
namespace %s.Controller%s {

	/**
	 * %s Controller.
	 */
	public class %s : Object {

		/**
		 * Index page for %s.
		 * @param state State object.
		 */
		public Result index( State state ) {
			return new Template.Root.index( "%s", state.request.headers );
		}

	}
}
""";
			string namespace = "";
			string class_name = name;
			if ( "." in name ) {
				namespace = "." + name.substring( 0, name.last_index_of(".") );
				class_name = name.substring( name.last_index_of(".") + 1 );
			}
			return write_scaffold(
				"Controller",
				name,
				scaffold.printf(
					application_name,
					application_name,
					namespace,
					class_name,
					class_name,
					class_name,
					application_name
				)
			);
		}

		/**
		 * Scaffold a Model class.
		 * @param name Class name
		 */
		private int scaffold_model( string name ) {
			string scaffold = """using Ambition;
namespace %s.Model%s {

	/**
	 * %s Model.
	 */
	public class %s : Object {

	}
}
""";
			string namespace = "";
			string class_name = name;
			if ( "." in name ) {
				namespace = "." + name.substring( 0, name.last_index_of(".") );
				class_name = name.substring( name.last_index_of(".") + 1 );
			}
			return write_scaffold(
				"Model",
				name,
				scaffold.printf(
					application_name,
					namespace,
					class_name,
					class_name
				)
			);
		}

		/**
		 * Scaffold a View class.
		 * @param name Class name
		 */
		private int scaffold_view( string name ) {
			string scaffold = """using Ambition.CoreView;
namespace %s.View%s {

	/**
	 * %s View.
	 */
	public class %s : None {

	}
}
""";
			string namespace = "";
			string class_name = name;
			if ( "." in name ) {
				namespace = "." + name.substring( 0, name.last_index_of(".") );
				class_name = name.substring( name.last_index_of(".") + 1 );
			}
			return write_scaffold(
				"View",
				name,
				scaffold.printf(
					application_name,
					namespace,
					class_name,
					class_name
				)
			);
		}

		/**
		 * Scaffold a Form class.
		 * @param name Class name
		 */
		private int scaffold_form( string name ) {
			string scaffold = """using Ambition.Form;
namespace %s.Form%s {

	/**
	 * %s Form.
	 */
	public class %s : FormDefinition {

		[Description( nick = "Example" )]
		public string example { get; set; }

	}
}
""";
			string namespace = "";
			string class_name = name;
			if ( "." in name ) {
				namespace = "." + name.substring( 0, name.last_index_of(".") );
				class_name = name.substring( name.last_index_of(".") + 1 );
			}
			return write_scaffold(
				"Form",
				name,
				scaffold.printf(
					application_name,
					namespace,
					class_name,
					class_name
				)
			);
		}

		/**
		 * Write the given scaffold content to the matching created file.
		 * @param path Path in src/ directory to create the file
		 * @param name Class name
		 * @param content Scaffolded content
		 */
		private int write_scaffold( string path, string name, string content ) {
			var fos = get_new_file( path, name );
			if ( fos == null ) {
				return -1;
			}

			try {
				fos.write( content.data );
			} catch (IOError e) {
				logger.error( "Cannot write to file.", e );
				return -1;
			}

			logger.info( "Created '%s'.".printf(full_path) );
			alter_cmakelists();
			return 0;
		}

		/**
		 * Open a file based on the class name given, creating directories if
		 * necessary.
		 * @param path Path in src/ directory to create the file
		 * @param name Class name
		 */
		private FileOutputStream? get_new_file( string path, string name ) {
			full_path = "src/%s/%s.vala".printf( path, name.replace( ".", "/" ) );
			string[] components = full_path.split("/");
			try {
				// Create directories if needed
				if ( components.length > 1 ) {
					string working_on = components[0];
					for ( int i = 1; i < components.length; i++ ) {
						var dir = File.new_for_path(working_on);
						if ( ! dir.query_exists() ) {
							dir.make_directory();
						}
						working_on = "%s/%s".printf( working_on, components[i] );
					}
				}
				var file = File.new_for_path(full_path);
				return file.create( FileCreateFlags.NONE );
			} catch ( Error e ) {
				logger.error( "Error creating file", e );
			}
			return null;
		}

		/**
		 * Add the created class to the project's CMakeLists.txt file.
		 */
		private bool alter_cmakelists() {
			var cmakelists = File.new_for_path("src/CMakeLists.txt");
			var builder = new StringBuilder();

			if ( !cmakelists.query_exists() ) {
				logger.error( "Fatal: Unable to load CMakeLists.txt." );
				return false;
			}
			try {
				var input_stream = new DataInputStream( cmakelists.read() );
				string line;
				while ( ( line = input_stream.read_line(null) ) != null ) {
					builder.append(line);
					builder.append("\n");
				}
			} catch ( Error e ) {
				logger.error( "Fatal: Unable to read CMakeLists.txt", e );
				return false;
			}

			try {
				var output_stream = cmakelists.replace( null, false, FileCreateFlags.REPLACE_DESTINATION );
				bool in_source_files = false;
				string last_section = "";
				foreach ( string line in builder.str.split("\n") ) {
					if ( in_source_files ) {
						string section = line.substring( 0, line.index_of("/") ).chug();
						if ( last_section == "Controller" ) {
							if ( section != last_section ) {
								string new_line = full_path.replace( "src/", "    " ) + "\n";
								output_stream.write( new_line.data );
							}
						}
						last_section = section;
					}
					if ( line == ")" ) {
						in_source_files = false;
					}
					if ( "SET( APP_VALA_FILES" in line ) {
						in_source_files = true;
					}
					output_stream.write( line.data );
					output_stream.write( "\n".data );
				}
			} catch ( Error e ) {
				logger.error( "Fatal: Unable to write CMakeLists.txt", e );
				return false;
			}


			return true;
		}

	}
}