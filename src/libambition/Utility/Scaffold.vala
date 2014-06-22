/*
 * Scaffold.vala
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
	 * Scaffold a new application.
	 */
	public class Scaffold : Object {
		private string base_path = null;
		private string[] profiles = null;

		public int run( string name, string[]? profiles = null ) {
			this.profiles = profiles;

			if ( name.down() == "test" || name.down() == "release" || name.down() == "debug" ) {
				stderr.printf( "Projects cannot be named 'test', 'release', or 'debug'.\n" );
				return 1;
			}

			// Find shared files
			foreach ( string dir in Environment.get_system_data_dirs() ) {
				var file_path = get_path( dir, "ambition-framework" );
				var share_dir = File.new_for_path(file_path);
				if ( share_dir.query_exists() ) {
					base_path = file_path;
					break;
				}
			}
			if ( base_path == null ) {
				stderr.printf( "Shared files not found, cannot continue. Please reinstall Ambition.\n" );
				return 1;
			}

			// Check profiles
			if ( profiles != null ) {
				foreach ( string profile in profiles ) {
					var profile_dir = File.new_for_path( get_path( base_path, "scaffold-%s".printf( profile.down() ) ) );
					if ( ! profile_dir.query_exists() ) {
						stderr.printf( "Profile '%s' does not exist.\n", profile.down() );
						return 1;
					}
				}
			}

			// Check if project exists
			var project_dir = File.new_for_path(name);
			if ( project_dir.query_exists() ) {
				stderr.printf( "Directory '%s' already exists.\n", name );
				return 1;
			}

			// Create project directory
			try {
				project_dir.make_directory();
			} catch (Error e) {
				stderr.printf( "Could not create project directory.\n" );
				return 1;
			}

			if ( ! make_scaffold(name) ) {
				return 1;
			}
			foreach ( string profile in profiles ) {
				if ( ! make_scaffold( name, profile ) ) {
					return 1;
				}
			}

			stdout.printf(
				"Project %s created. Type \"cd %s\", and then \"ambition run\" to test.\n",
				name,
				name
			);

			return 0;
		}

		private bool file_append( string path, string content, HashMap<string,string> options ) {
			var out_file_path = populate_template( get_path( options["namespace"], path ), options );
			var out_file = File.new_for_path(out_file_path);
			bool created = false;
			try {
				FileOutputStream file_stream;
				if ( out_file.query_exists() ) {
					file_stream = out_file.append_to( FileCreateFlags.NONE );
				} else {
					created = true;
					file_stream = out_file.create( FileCreateFlags.REPLACE_DESTINATION );
				}
				if ( ! out_file.query_exists() ) {
					stderr.printf( "Cannot create '%s'.\n", path );
					return false;
				}
				var data_stream = new DataOutputStream(file_stream);
				data_stream.put_string( populate_template( content, options ) );
			} catch (Error e) {
				stderr.printf( e.message );
				return false;
			}
			stdout.printf( "%s %s: %s\n", ( created ? "Created" : "Modified" ), ( options["profile"] == null ? "default" : options["profile"] ), out_file_path );
			return true;
		}

		private bool file_create( string path, string content, HashMap<string,string> options ) {
			var out_file_path = populate_template( get_path( options["namespace"], path ), options );
			var out_file = File.new_for_path(out_file_path);
			try {
				FileOutputStream file_stream = out_file.create( FileCreateFlags.REPLACE_DESTINATION );
				if ( ! out_file.query_exists() ) {
					stderr.printf( "Cannot create '%s'.\n", path );
					return false;
				}
				var data_stream = new DataOutputStream(file_stream);
				data_stream.put_string( populate_template( content, options ) );
			} catch (Error e) {
				stderr.printf( e.message );
				return false;
			}
			stdout.printf( "Created %s: %s\n", ( options["profile"] == null ? "default" : options["profile"] ), out_file_path );
			return true;
		}

		private bool make_scaffold( string name, string? profile = null ) {
			var scaffold_directory = get_path( base_path, "scaffold" );
			if ( profile != null ) {
				scaffold_directory = scaffold_directory + "-%s".printf(profile);
			}

			var manifest = ScaffoldManifest.load_manifest(scaffold_directory);

			var options = new HashMap<string,string>();
			options["namespace"] = name;
			options["profile"] = profile;
			options["profiles"] = ( profiles == null ? "" : string.joinv( ",", profiles ) );

			// creates
			if ( manifest.creates != null && manifest.creates.length > 0 ) {
				foreach ( string path in manifest.creates ) {
					if ( is_directory( get_path( scaffold_directory, path ) ) ) {
						var dir = File.new_for_path( get_path( name, path ) );
						try {
							dir.make_directory();
						} catch (Error e) {
							stderr.printf( "Unable to create directory '%s': %s", path, e.message );
						}
					} else {
						var template = get_template( get_path( scaffold_directory, path ) );
						if ( template == null ) {
							stderr.printf( "Unable to pull data from file '%s'\n", get_path( scaffold_directory, path ) );
							return false;
						}

						file_create( path, template, options );
					}
				}
			}

			// appends
			if ( manifest.appends != null && manifest.appends.length > 0 ) {
				foreach ( string path in manifest.appends ) {
					var template = get_template( get_path( scaffold_directory, path ) );
					if ( template == null ) {
						stderr.printf( "Unable to pull data from file '%s'\n", get_path( scaffold_directory, path ) );
						return false;
					}

					file_append( path, template, options );
				}
			}

			// deletes
			if ( manifest.deletes != null && manifest.deletes.length > 0 ) {
				foreach ( string path in manifest.deletes ) {
					try {
						var rm_file = File.new_for_path( get_path( name, path ) );
						if ( rm_file.query_exists() ) {
							rm_file.delete();
							stdout.printf( "Deleted %s: %s/%s\n", ( profile == null ? "default" : profile ), name, path );
						}
					} catch ( Error e ) {
						stderr.printf( e.message );
						return false;
					}
				}
			}

			// pkgs
			if ( manifest.pkgs != null && manifest.pkgs.length > 0 ) {
				foreach ( string pkg in manifest.pkgs ) {
				}
			}

			// vapis
			if ( manifest.vapis != null && manifest.vapis.length > 0 ) {
				foreach ( string vapi in manifest.vapis ) {
				}
			}

			// plugins
			if ( manifest.plugins != null && manifest.plugins.length > 0 ) {
				foreach ( string plugin in manifest.plugins ) {
				}
			}

			// config
			if ( manifest.config != null && manifest.config.length > 0 ) {
				file_append( "config/%s.conf".printf( name.down() ), string.joinv( "\n", manifest.config ), options );
			}

			return true;
		}

		private bool is_directory( string path ) {
			var file = File.new_for_path(path);

			if ( file.query_exists() && file.query_file_type( FileQueryInfoFlags.NONE ) == FileType.DIRECTORY ) {
				return true;
			}
			return false;
		}

		private string? get_template( string path ) {
			var sb = new StringBuilder();
			var file = File.new_for_path(path);

			if ( !file.query_exists() ) {
				stderr.printf( "Fatal: Unable to load template '%s'", path );
				return null;
			}
			try {
				var input_stream = new DataInputStream( file.read() );
				string line;
				while ( ( line = input_stream.read_line(null) ) != null ) {
					sb.append(line);
					sb.append("\n");
				}
			} catch ( Error e ) {
				stderr.printf( "Fatal: Unable to read template '%s'", path );
				return null;
			}

			return sb.str;
		}
		
		private string? populate_template( string template, HashMap<string,string> options ) {
			string populated = template;
			foreach ( string key in options.keys ) {
				var token = "%%%%%s%%%%".printf(key);
				if ( options[key] != null ) {
					populated = populated.replace( token, options[key] );
				} else {
					populated = populated.replace( token, "" );
				}
			}

			return populated;
		}

		private string get_path( string name, string path ) {
			return name + "/" + path;
		}

		/**
		 * Enumerate the given directory structure.
		 *
		 * @param directory_path Directory to search
		 * @return ArrayList of paths
		 */
		private ArrayList<string> enumerate_directory( string directory_path ) {
			var list = new ArrayList<string>();
			FileInfo file_info;
			var directory = File.new_for_path(directory_path);
			try {
				var enumerator = directory.enumerate_children(
					FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, 0
				);

				while ( ( file_info = enumerator.next_file() ) != null ) {
					if ( file_info.get_file_type() == FileType.DIRECTORY ) {
						list.add( get_path( directory_path, file_info.get_name() ) + "/" );
						list.add_all( enumerate_directory( get_path( directory_path, file_info.get_name() ) ) );
					} else {
						list.add( get_path( directory_path, file_info.get_name() ) );
					}
				}
			} catch (Error e) {
				stderr.printf( "Error while enumerating directory '%s': %s", directory_path, e.message );
			}

			return list;
		}
	}
}
