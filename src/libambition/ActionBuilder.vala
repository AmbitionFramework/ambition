/*
 * ActionBuilder.vala
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

using Ambition;
using Gee;

namespace Ambition {
	/**
	 * Represents an unrecoverable error during action parsing.
	 */
	public errordomain ActionBuilderError {
		WRITE_ERROR,
		READ_ERROR,
		PARSE_ERROR
	}

	/**
	 * Parses action configuration to create an Actions generator.
	 */
	public class ActionBuilder : Object {
		private const string class_template = """/*
 * Ambition generated actions class
 * This file is auto-generated. Do not edit!
 */

using Ambition;

%s
	public class Actions : Ambition.Actions {

		public override Ambition.Action[] actions() {
%s
		}
	}
%s
""";

		/**
		 * Generate an actions file.
		 * @param target_namespace Namespace of target class
		 * @param source_directory Directory where actions.conf is stored
		 * @param destination_directory Directory to generate file into
		 */
		public void run( string target_namespace, string source_directory, string destination_directory ) throws ActionBuilderError {
			string dispatch_filename = destination_directory + "/Actions.vala";
			FileStream dispatch_file = FileStream.open( dispatch_filename, "w" );
			if ( dispatch_file == null ) {
				throw new ActionBuilderError.WRITE_ERROR( "Cannot write to %s".printf(dispatch_filename) );
			}

			dispatch_file.printf(
				class_template,
				( target_namespace != null ? "namespace %s {".printf(target_namespace) : "" ),
				parse_action_configuration( source_directory, "actions.conf" ),
				( target_namespace != null ? "}" : "" )
			);
		}

		/**
		 * Parse the given action configuration and return valid Vala code to
		 * generate routes.
		 * @param source_directory Directory where actions.conf is stored
		 * @param action_file Filename of actions configuration
		 */
		public string? parse_action_configuration( string source_directory, string action_file ) throws ActionBuilderError {
			string line;
			var controllers = new HashSet<string>();
			var actions = new ArrayList<string>();

			try {
				var file = File.new_for_path( "%s/%s".printf( source_directory, action_file ) );

				if ( !file.query_exists() ) {
					throw new ActionBuilderError.READ_ERROR( "Unable to read %s, failing.".printf(action_file) );
				}

				var input_stream = new DataInputStream( file.read() );
				while ( ( line = input_stream.read_line(null) ) != null ) {
					if ( line.length == 0 || line.has_prefix("#") ) {
						continue;
					}

					string? result = parse_action_line( line, controllers );
					if ( result != null ) {
						actions.add(result);
					}
				}

				return build_action_block( controllers, actions );

			} catch (Error e) {
				throw new ActionBuilderError.READ_ERROR( "Unable to read or open %s, failing: %s".printf( action_file, e.message ) );
			}

		}

		public string? build_action_block( HashSet<string> controllers, ArrayList<string> actions ) {
			string indent = "			";
			var builder = new StringBuilder();
			foreach ( string controller in controllers ) {
				builder.append( "%svar %s = new Controller.%s();\n".printf( indent, normalize_controller(controller), controller ) );
			}

			// Haaaaaacks
			string[] actions_array = new string[actions.size];
			int a_index = 0;
			foreach ( string a in actions ) {
				actions_array[a_index++] = a;
			}

			builder.append( "%sAmbition.Action[] actions = {\n".printf(indent) );
			builder.append( "%s	%s\n".printf( indent, string.joinv( ",\n				", actions_array ) ) );
			builder.append( "%s};\n%sreturn actions;".printf( indent, indent ) );

			return builder.str;
		}

		public string? parse_action_line( string line, HashSet<string> controllers ) throws ActionBuilderError {
			var info = is_valid_action_line(line);
			if ( info == null ) {
				throw new ActionBuilderError.PARSE_ERROR( "Invalid action line: '%s'".printf(line) );
			}

			// Path/Regex
			string regex = "";
			string path = info.fetch(1).chug().strip();
			if ( path.length > 2 && path.has_prefix("/") && path.has_suffix("/") ) {
				regex = path;
			} else {
				var re_named = /\[([^\]]+)\]/;
				try {
					path = re_named.replace( path, -1, 0, "(?<\\1>.+?)/?" );
				} catch (RegexError e) {
					Logger.error( "Unable to create matches from placeholders in path. (%s)".printf( e.message ) );
				}
				regex = "/^" + path.replace( "/", "\\/" );
				if ( regex.has_suffix("*") ) {
					regex = regex.substring( 0, regex.length - 1 ) + ".*";
				} else {
					regex = regex + "\\/?";
				}
				regex = regex + "$/";
			}

			// Method(s)
			string method_line = "";
			string[] methods = info.fetch(2).chug().strip().split(",");
			foreach ( string method in methods ) {
				string clean = method.chug().strip();

				HttpMethod hm = HttpMethod.from_string(clean);
				if ( hm == HttpMethod.NONE ) {
					throw new ActionBuilderError.PARSE_ERROR( "Invalid HTTP method %s".printf(clean) );
				}

				method_line = method_line + ".allow_method( HttpMethod.%s )".printf(clean);
			}

			// Target(s)
			string target_line = "";
			string[] targets = info.fetch(6).chug().strip().split(",");
			foreach ( string target in targets ) {
				string clean = target.chug().strip();
				string controller = clean.substring( 0, clean.last_index_of(".") );
				string method = clean.substring( clean.last_index_of(".") + 1 );

				target_line = target_line + ".add_target_method( new Ambition.ActionMethod( %s.%s, \"/%s/%s\" ) )".printf(
					normalize_controller(controller),
					method,
					pathify_controller(controller),
					method
				);
				controllers.add(controller);
			}

			return "( new Ambition.Action() ).regex(%s)%s%s".printf(
				regex,
				method_line,
				target_line
			);
		}

		/**
		 * Determine if action line matches the relatively loose regex check.
		 * Return a MatchInfo if valid, null if invalid.
		 * @param line Action line
		 */
		public MatchInfo? is_valid_action_line( string line ) {
			var re_line = /^(\/.*)\s+(((CONNECT|DELETE|GET|HEAD|OPTIONS|POST|PUT|TRACE|ALL)(, ?)?)+)\s+(.*)([\r\n])?$/;
			MatchInfo info = null;
			if ( re_line.match( line, 0, out info ) ) {
				return info;
			}
			return null;
		}

		public string normalize_controller( string controller_name ) {
			return controller_name.replace( ".", "_" ).down();
		}

		public string pathify_controller( string controller_name ) {
			return controller_name.replace( ".", "/" ).down();
		}
	}
}
