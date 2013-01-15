/*
 * DispatcherBuilder.vala
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

namespace Ambition.Utility {
	/**
	 * Parses controllers and dispatch methods to auto-generate a dispatch
	 * class. At this time, one cannot define their own annotations without
	 * extending the Vala compiler. Once that is is allowed, theoretically,
	 * this class will either become obsolete or change drastically.
	 */
	public class DispatchBuilder : Object {
		private HashMap<string,DispatchType.IDispatchType> dispatchers = new HashMap<string,DispatchType.IDispatchType>();
		private const string class_template = """/*
 * Ambition generated dispatch class
 * This file is auto-generated. Do not edit!
 */

using Ambition;
using Gee;

%s
	public class GeneratedDispatch : Object {
		public ArrayList<Ambition.Action?> actions;
		public ArrayList<Ambition.Hook?> hooks;

		public GeneratedDispatch() {
			this.actions = new ArrayList<Ambition.Action?>();
			this.hooks = new ArrayList<Ambition.Hook?>();
			load_paths();
		}

		private void load_paths() {
%s
		}
	}
%s
""";

		public DispatchBuilder() {
			// Cache DispatchType objects so we can reuse them later.
			dispatchers["Begin"] = new DispatchType.Begin();
			dispatchers["End"] = new DispatchType.End();
			dispatchers["Index"] = new DispatchType.Index();
			dispatchers["MethodName"]= new DispatchType.MethodName();
			dispatchers["Path"] = new DispatchType.Path();
			dispatchers["Regex"] = new DispatchType.Regex();
		}

		/**
		 * Generate a dispatch file.
		 * @param target_namespace Namespace of target class
		 * @param source_directory Directory to parse
		 * @param destination_directory Directory to generate file into
		 */
		public void run( string target_namespace, string source_directory, string destination_directory ) {
			var controller_list = get_controllers(source_directory);
			string dispatch_filename = destination_directory + "/GeneratedDispatch.vala";
			FileStream dispatch_file = FileStream.open( dispatch_filename, "w" );
			if ( dispatch_file == null ) {
				stdout.printf( "Cannot write to %s\n", dispatch_filename );
			}

			var action_sub = new StringBuilder();
			foreach ( string controller in controller_list.keys ) {
				action_sub.append(
					parse_dispatches( controller, controller_list.get(controller) )
				);
				action_sub.append("\n");
			}

			dispatch_file.printf(
				class_template,
				( target_namespace != null ? "namespace %s {".printf(target_namespace) : "" ),
				action_sub.str,
				( target_namespace != null ? "}" : "" )
			);
		}

		/**
		 * Given the output from get_controllers, parse out the dispatch methods
		 * and methods into action calls
		 * @param controller Full controller class name
		 * @param methods HashMap containing the dispatch name and method
		 */
		public string parse_dispatches( string controller, ArrayList<string> methods ) {
			if ( controller == null || controller.length == 0 ) {
				return "";
			}
			var builder = new StringBuilder();
			string lower = controller.replace( ".", "_" ).down();

			/*
			 * If the controller is not fully defined, or lacks a class, assume
			 * the developer has a reason for this, and don't add it to dispatch
			 */
			if ( lower.has_suffix("_") ) {
				return "";
			}

			string indent = "            ";
			builder.append( indent + "var %s = new %s();\n".printf( lower, controller ) );
			foreach ( string dispatch_concat in methods ) {
				string[] dispatch_pair = dispatch_concat.split("]]|");
				builder.append(
					indent + parse_dispatch_method( controller, dispatch_pair[0], dispatch_pair[1] )
				);	
			}
			return builder.str;
		}

		/**
		 * Parse a method dispatch type and method into an action string
		 * @param controller Full controller name with namespaces
		 * @param dispatch_annotation Full annotation in the controller
		 * @param method_name Name of the method within the controller
		 */
		public string? parse_dispatch_method( string controller, string dispatch_annotation, string method_name ) {
			if ( !dispatch_annotation.has_prefix("Dispatch") ) {
				stderr.printf( "Unknown dispatch method '%s'.\n", dispatch_annotation );
				exit(1);
			}

			MatchInfo info = null;
			Regex re_signature = null;
			try {
				re_signature = new Regex("^Dispatch(\\w+)( \\((.*)\\))?$");
			} catch (RegexError re) {
				return null;
			}
			if ( re_signature.match( dispatch_annotation, 0, out info ) ) {
				string dispatch_method_name = info.fetch(1);

				// Bust out parameter list info map
				var param_map = new HashMap<string,string>();
				if ( info.get_match_count() > 2 ) {
					string param_list = info.fetch(3);
					string[] param_comma_list = param_list.split(", ");
					foreach ( string equality in param_comma_list ) {
						string[] equality_pair = equality.split(" = ");
						string val = equality_pair[1];
						if ( val.has_prefix("\"") ) {
							val = val.substring(1);
						}
						if ( val.has_suffix("\"") ) {
							val = val.substring( 0, val.length - 1 );
						}
						param_map.set( equality_pair[0], val );
					}
				}

				if ( dispatchers.has_key(dispatch_method_name) ) {
					return dispatchers[dispatch_method_name].parse( controller, method_name, param_map ) + "\n";
				} else {
					stderr.printf( "No such dispatch method '%s'.\n", dispatch_method_name );
					exit(1);
				}
			} else {
				stderr.printf( "Cannot parse dispatch annotation '%s'.\n", dispatch_annotation );
				exit(1);
			}

			return "";
		}

		/**
		 * Retrieve a HashMap containing a controller name and a source file
		 */
		public HashMap<string,ArrayList<string>> get_controllers( string source_directory ) {
			var map = new HashMap<string,ArrayList<string>>();
			var list = enumerate_directory( source_directory + "/Controller" );
			foreach ( string path in list ) {
				string cmd = "valac %s --fast-vapi tmp.vapi".printf(path);
				try {
					Process.spawn_command_line_sync(cmd);
					var dispatch_pairs = parse_vapi("tmp.vapi");
					string full_path = "%s.%s".printf(
						dispatch_pairs.get( dispatch_pairs.size - 1 ).split("]]|")[1],
						dispatch_pairs.get( dispatch_pairs.size - 2 ).split("]]|")[1]
					);
					map.set( full_path, (ArrayList) dispatch_pairs.slice( 0, dispatch_pairs.size - 2 ) );

				} catch (Error e) {
					stderr.printf( "Could not start valac: %s\n", e.message );
				}
			}
			return map;
		}

		/*
		 * This should be an ArrayList of string[] or some other kind of pair,
		 * but ArrayList doesn't want to contain string[], so we hack. I need
		 * to find something better. TODO.
		 */
		public ArrayList<string> parse_vapi( string file_path ) {
			var dispatch_pairs = new ArrayList<string>();
			var namespace = new ArrayList<string>();
			string line;
			string class_name = "";
			string dispatch_method = null;
			Regex re_namespace = null, re_class = null, re_dispatch = null, re_action = null;
			try {
				re_namespace = new Regex("namespace (.*?) \\{");
				re_class = new Regex("class (.*?) [\\{:]");
				re_dispatch = new Regex("\\[(Dispatch.*?)\\]$");
				re_action = new Regex("public Result (.*?) \\(State state\\)");
			} catch ( RegexError re ) {
				stderr.printf( re.message );
				exit(1);
			}

			try {
				var file = File.new_for_path(file_path);

				if ( !file.query_exists() ) {
					stderr.printf( "Unable to parse '%s', failing.\n", file_path );
					exit(1);
				}

				var input_stream = new DataInputStream( file.read() );
				while ( ( line = input_stream.read_line(null) ) != null ) {
					MatchInfo info = null;
					if ( re_namespace.match( line, 0, out info ) ) {
						namespace.add( info.fetch(1) );
					} else if ( re_class.match( line, 0, out info ) ) {
						class_name = info.fetch(1);
					} else if ( re_dispatch.match( line, 0, out info ) ) {
						dispatch_method = info.fetch(1);
					} else if ( re_action.match( line, 0, out info ) ) {
						string method = info.fetch(1);
						if ( method == "begin" ) {
							dispatch_pairs.add( "DispatchBegin]]|" + method );
						} else if ( dispatch_method != null ) {
							dispatch_pairs.add( dispatch_method + "]]|" + method);
							dispatch_method = null;
						}
					}
				}

				// Build namespace path, since joinv seems to segfault on os x
				var ns = new StringBuilder();
				foreach ( string node in namespace ) {
					if ( ns.len > 0 ) {
						ns.append(".");
					}
					ns.append(node);
				}
				
				dispatch_pairs.add( "_class_name]]|" + class_name );
				dispatch_pairs.add( "_namespace]]|" + ns.str );
				file.delete();
			} catch ( Error e ) {

			}
			return dispatch_pairs;
		} 

		private ArrayList<string> enumerate_directory( string directory_path ) {
			var list = new ArrayList<string>();
			try {
				FileInfo file_info;
				var directory = File.new_for_path(directory_path);
				var enumerator = directory.enumerate_children(
					FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, 0
				);

				while ( ( file_info = enumerator.next_file() ) != null ) {
					if ( file_info.get_file_type() == FileType.DIRECTORY ) {
						list.add_all( enumerate_directory( directory_path + "/" + file_info.get_name() ) );
					} else if ( file_info.get_name().has_suffix(".vala") ) {
						list.add( directory_path + "/" + file_info.get_name() );
					}
				}
			} catch (Error e) {
				stderr.printf( "Error in dispatch-build: %s\n", e.message );
			}
			return list;
		}
	}
}
