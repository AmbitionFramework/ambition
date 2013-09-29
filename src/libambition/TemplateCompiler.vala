/*
 * TemplateCompiler.vala
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

namespace Ambition {
	/**
	 * Represents an unrecoverable error during a template compilation.
	 */
	public errordomain TemplateCompileError {
		BAD_COMMAND,
		INVALID_USAGE,
		TEMPLATE_NOT_FOUND,
		WRITE_ERROR,
		UNKNOWN_ERROR
	}

	/**
	 * Functionality to compile Ambition templates into .vala source files. Used
	 * by the ambition binary.
	 */
	public class TemplateCompiler {
		/**
		 * Namespace of the template, used in the namespace directive.
		 */
		public string namespace { get; set; }
		private string root_path { get; set; }
		private const string[] VALID_KEYWORDS = {
			"if",
			"else",
			"for",
			"foreach",
			"while",
			"do",
			"break",
			"continue",
			"switch",
			"case",
			"default",
			"try",
			"catch",
			"finally"
		};

		/**
		 * Compile the given template filename into the corresponding Vala
		 * source.
		 *
		 * @param template_name File name of the template.
		 * @throws TemplateCompileError on failure
		 * @return string containing Vala source
		 */
		// TODO: Refactor and separate components of compiler
		public string? compile( string template_name ) throws TemplateCompileError {
			var builder = new StringBuilder();

			int line_number = 0;
			string parameters = "";
			string verbatim = "\"\"\"";
			Regex interpolate = null;
			Regex process = null;
			try {
				interpolate = new Regex("@\\{(.*?)\\}");
				process = new Regex("process\\(\\s*['\"](.*?)['\"](,\\s*(.*?)\\s*)?\\)$");
			} catch ( RegexError re ) {
				stderr.printf( re.message );
				return null;
			}

			string path = template_name.replace( root_path + "/", "" ).replace( ".vtmpl", "" );
			string[] path_array = path.split("/");
			string class_name = path_array[ path_array.length - 1 ];
			string local_namespace = namespace + ".View.Template";
			for ( int i = 0; i < path_array.length - 1; i++ ) {
				local_namespace = local_namespace + "." + path_array[i];
			}

			var file = File.new_for_path(template_name);

			if ( !file.query_exists() ) {
				var msg = "Template '%s' no longer exists or is unavailable.\n".printf( file.get_path() );
				throw new TemplateCompileError.TEMPLATE_NOT_FOUND(msg);
			}

			// If configuration defines a base class, use that
			string base_class = Config.lookup_with_default( "template.base_class", "Ambition.CoreView.Template" );

			// If configuration contains extra using statements, add them first
			add_usings(builder);

			// Write standard header
			builder.append( "/* This file is auto generated, do not edit! */\n");
			builder.append( "namespace %s {\n".printf(local_namespace) );
			builder.append( "    public class " + class_name + " : " + base_class + " {\n" );
			builder.append( "        public override Ambition.State state { get; set; }\n");
			builder.append( "        public override int64 size { get; set; }\n");
			builder.append( "%%%PARAMS_PARSED%%%\n" );
			builder.append( "        public " + class_name + "(%%%PARAMS%%%) {\n" );
			builder.append( "%%%PARAMS_PARSED_SET%%%" );
			builder.append( "        }\n\n" );
			builder.append( "        public override string to_string() {\n" );
			builder.append( "            StringBuilder b = new StringBuilder();\n" );
			builder.append( "            state.ping();\n");

			// Parse file into vala source
			try {
				var input_stream = new DataInputStream( file.read() );
				input_stream.set_newline_type( DataStreamNewlineType.ANY );
				string line;
				while ( ( line = input_stream.read_line(null) ) != null ) {
					line_number++;
					string left_line = line.chug();
					if ( left_line.has_prefix("@") && !left_line.has_prefix("@{") ) {
						left_line = "@" + left_line.substring(1).chug(); // Remove leading space after @
						if ( left_line.has_prefix("@parameters") ) {
							parameters = left_line.chomp().replace( "@parameters(", "" );

						} else if ( left_line.has_prefix("@using") ) {
							builder.prepend( "using " + left_line.replace( "@using ", "" ) + "; // L%d\n".printf(line_number) );

						} else if ( left_line.has_prefix("@process") ) {
							MatchInfo info = null;
							if ( process.match( left_line, 0, out info ) ) {
								string template = info.fetch(1);
								builder.append("            b.append(");
								builder.append( "( new Template." + template + "(" );
								if ( info.get_match_count() > 2 ) {
									builder.append( info.fetch(3) );
								}
								builder.append( ").to_string_with_state(state) ) ); //L%d\n".printf(line_number) );
							} else {
								var msg = "Invalid usage of process in '%s' on line %d: %s\n".printf( template_name, line_number, line );
								throw new TemplateCompileError.INVALID_USAGE(msg);
							}

						} else if ( left_line.has_prefix("@*") ) {
							continue;

						} else {
							if ( check_valid(left_line) ) {
								builder.append( "            " + left_line.substring(1) + " // L%d\n".printf(line_number) );
							} else {
								var msg = "Unrecognized or unavailable command in '%s' on line %d: %s\n".printf( template_name, line_number, line );
								throw new TemplateCompileError.BAD_COMMAND(msg);
							}
						}
					} else {
						builder.append(
							"            b.append("
							+ verbatim
							+ interpolate.replace( line, -1, 0, verbatim + " + \\1 + " + verbatim )
							+ verbatim
							+ " + \"\\n\" "
							+ "); // L%d".printf(line_number)
							+ "\n"
						);
					}
				}
			} catch ( Error e ) {
				var msg = "Unknown error parsing '%s': %s\n".printf( template_name, e.message );
				throw new TemplateCompileError.UNKNOWN_ERROR(msg);
			}


			// Close out file
			builder.append("            return b.str;\n");
			builder.append("        }\n    }\n");
			builder.append("}\n");

			var param_builder = new StringBuilder();
			var param_set_builder = new StringBuilder();
			parameters = parameters.substring( 0, parameters.length - 1 );
			foreach ( string param in parameters.chomp().chug().split(", ") ) {
				string default_value = " ";
				if ( "=" in param ) {
					default_value = " default = %s; ".printf( param.substring( param.index_of("=") + 1 ).chug() );
					param = param.substring( 0, param.index_of("=") ).chomp();
				}
				string var_name = param.substring( param.index_of(" ") + 1 ).chug().chomp();
				param_builder.append( "        private %s { get; set;%s}\n".printf( param, default_value ) );
				param_set_builder.append( "            this.%s = %s;\n".printf( var_name, var_name ) );
			}
			return builder.str
				.replace( "%%%PARAMS%%%", parameters )
				.replace( "%%%PARAMS_PARSED%%%", param_builder.str )
				.replace( "%%%PARAMS_PARSED_SET%%%", param_set_builder.str );
		}

		/**
		 * Determines if the keyword after @ is an allowed keyword.
		 * 
		 * @param line Incoming line of text
		 * @return bool True, if valid.
		 */
		private bool check_valid( string line ) {
			// Closes block, call it good
			if ( line == "@}" || line == "@} else {" ) {
				return true;
			}

			// Return true if keyword matches valid constant
			foreach ( string valid in VALID_KEYWORDS ) {
				if ( line.has_prefix( "@" + valid + " (" ) || line.has_prefix( "@" + valid + "(" ) ) {
					return true;
				}
			}

			return false;
		}

		/**
		 * Compile all vtmpl files in the given directory to vala.
		 *
		 * @param input_path Directory to search for vtmpl files
		 * @param output_path Directory to store vala files
		 */
		public void compile_all( string input_path, string output_path ) throws TemplateCompileError {
			root_path = input_path;

			init_config();

			// Convert files to vala
			var file_list = new ArrayList<string>();
			var files = enumerate_directory( input_path, ".vtmpl" );
			foreach ( string template in files ) {
				string vala_source;
				try {
					vala_source = compile(template);
				} catch (TemplateCompileError e) {
					e.message = template + ": " + e.message;
					throw e;
				}
				string path = template.replace( root_path + "/", "" ).replace( ".vtmpl", ".vala" ).replace( "/", "." );
				write_to_file( vala_source, output_path + "/" + path );
				file_list.add( output_path + "/" + path );
			}

			stdout.printf( "%s", arraylist_joinv( ";", file_list ) );
		}

		/**
		 * Write given source to output file, or simply, put blob in thing.
		 *
		 * @param source Source string
		 * @param path Output file path
		 */
		private void write_to_file( string source, string path ) throws TemplateCompileError {
			var file = File.new_for_path(path);
			if ( file.query_exists() ) {
				try {
					file.delete();
				} catch (Error de) {
					var msg = "Unable to delete existing file at '%s': %s".printf( path, de.message );
					throw new TemplateCompileError.WRITE_ERROR(msg);
				}
			}

			try {
				var file_stream = file.create( FileCreateFlags.NONE );

				if ( !file.query_exists() ) {
					var msg = "Unable to write to file: %s\n".printf( path );
					throw new TemplateCompileError.WRITE_ERROR(msg);
				}

				var data_stream = new DataOutputStream(file_stream);
				data_stream.put_string(source);
			} catch (Error we) {
				var msg = "Unable to write to file '%s': %s".printf( path, we.message );
				throw new TemplateCompileError.WRITE_ERROR(msg);
			}
   		
		}

		/**
		 * Enumerate the given directory for files.
		 *
		 * @param directory_path Directory to search for vtmpl files
		 * @param search Suffix to search for
		 * @return ArrayList of paths
		 */
		private ArrayList<string> enumerate_directory( string directory_path, string search ) {
			var list = new ArrayList<string>();
			FileInfo file_info;
			var directory = File.new_for_path(directory_path);
			try {
				var enumerator = directory.enumerate_children(
					FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, 0
				);

				while ( ( file_info = enumerator.next_file() ) != null ) {
					if ( file_info.get_file_type() == FileType.DIRECTORY ) {
						list.add_all( enumerate_directory( directory_path + "/" + file_info.get_name(), search ) );
					} else if ( file_info.get_name().has_suffix(search) ) {
						list.add( directory_path + "/" + file_info.get_name() );
					}
				}
			} catch (Error e) {
				Logger.error( "Error while enumerating directory '%s': %s".printf( directory_path, e.message ) );
			}

			return list;
		}

		/**
		 * Based on configuration (for now), add using statements if required.
		 * @param builder StringBuilder object
		 */
		private void add_usings( StringBuilder builder ) {
			string? usings = Config.lookup("template.using");
			if ( usings != null ) {
				foreach ( var using in usings.replace( " ", "" ).split(",") ) {
					builder.append( "using %s;\n".printf(using) );
				}
			}
		}

		private void init_config() {
			Config.set_value( "ambition.app_name", namespace );
			Config.set_value( "ambition.app_path", Environment.get_current_dir() + "/.." );
		}
	}
}
