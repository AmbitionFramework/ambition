/*
 * Utility.vala
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

		// Get appname from CMakeLists.txt
		var cmakelists = File.new_for_path("CMakeLists.txt");
		if ( !cmakelists.query_exists() ) {
			Logger.error( "Fatal: Unable to load CMakeLists.txt." );
			return null;
		}
		try {
			var input_stream = new DataInputStream( cmakelists.read() );
			string line;
			while ( ( line = input_stream.read_line(null) ) != null ) {
				if ( "set (APPNAME " in line ) {
					int start = line.index_of("NAME ") + 5;
					string app_name = line.substring(
						start,
						line.index_of(")") - start
					);
					return app_name;
				}
			}
		} catch ( Error e ) {
			Logger.error( "Fatal: Unable to read CMakeLists.txt" );
			return null;
		}

		return null;
	}

	/**
	 * Soft wrap a string at a given column.
	 * @param text Text to display and wrap
	 * @param indent Default = 4, level of indentation for string
	 */
	public static string? wrap_string( string text, int indent = 4 ) {
		int wrap_at = 80;
		var big_sb = new StringBuilder();
		var sb = new StringBuilder();
		foreach ( string word in text.split(" ") ) {
			if ( sb.len >= wrap_at || sb.len + word.length > wrap_at ) {
				big_sb.append( "%s\n".printf(sb.str) );
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
		big_sb.append(sb.str);
		return big_sb.str;
	}

	/**
	 * Soft wrap a string at a given column.
	 * @param text Text to display and wrap
	 * @param indent Default = 4, level of indentation for string
	 */
	public static void wrap( string text, int indent = 4 ) {
		stdout.printf( "%s\n", wrap_string( text, indent ) );
	}

	/**
	 * Alter a config key in the current application.
	 * @param config_key Configuration key
	 * @param config_value Configuration value
	 */
	public static void alter_config( string config_key, string config_value ) {
		var sb = new StringBuilder();
		bool found = false;
		try {
			var file = File.new_for_path( "config/%s.conf".printf( get_application_name().down() ) );

			if ( !file.query_exists() ) {
				stderr.printf( "Config file not available where expected.\n" );
				return;
			}

			// Read it
			var input_stream = new DataInputStream( file.read() );
			string line = null;
			while ( ( line = input_stream.read_line(null) ) != null ) {
				// Skip potential comments
				if ( !line.has_prefix("#") && !line.has_prefix("//") && "=" in line ) {
					string key = line.substring( 0, line.index_of("=") ).chomp().chug();
					if ( key == config_key ) {
						found = true;
						sb.append( "%s = %s\n".printf( config_key, config_value ) );
					} else {
						sb.append( "%s\n".printf(line) );
					}
				} else {
					sb.append( "%s\n".printf(line) );
				}
			}
			if ( found == false ) {
				sb.append( "%s = %s\n".printf( config_key, config_value ) );
			}

			// Write it
			string etag;
			file.replace_contents( sb.str.data, null, false, FileCreateFlags.REPLACE_DESTINATION, out etag );

		} catch (Error e) {

		}
	}

	/**
	 * Alter a config key in the current application.
	 * @param lines Lines to add or modify
	 */
	public static bool alter_cmakelists( ArrayList<string> lines ) {
		var cmakelists = File.new_for_path("src/CMakeLists.txt");
		var builder = new StringBuilder();

		if ( !cmakelists.query_exists() ) {
			Logger.error( "Fatal: Unable to load CMakeLists.txt." );
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
			Logger.error( "Fatal: Unable to read CMakeLists.txt" );
			return false;
		}

		try {
			var output_stream = cmakelists.replace( null, false, FileCreateFlags.REPLACE_DESTINATION );
			bool in_source_files = false;
			foreach ( string line in builder.str.split("\n") ) {
				if ( in_source_files ) {
					var stripped = line.chomp().chug();
					if ( stripped in lines ) {
						lines.remove(stripped);
					}
				}
				if ( in_source_files && line == ")" ) {
					foreach ( var new_line in lines ) {
						output_stream.write( "    %s\n".printf(new_line).data );
					}
					in_source_files = false;
				}
				if ( "SET( APP_VALA_FILES" in line ) {
					in_source_files = true;
				}
				output_stream.write( line.data );
				output_stream.write( "\n".data );
			}
		} catch ( Error e ) {
			Logger.error( "Fatal: Unable to write CMakeLists.txt" );
			return false;
		}

		return true;
	}
}
