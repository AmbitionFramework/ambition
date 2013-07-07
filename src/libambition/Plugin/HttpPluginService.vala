/*
 * HttpPluginService.vala
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
using Soup;
namespace Ambition.Plugin {
	/**
	 * HTTP plugin service.
	 */
	public class HttpPluginService : Object,IPluginService {
		public HashMap<string,string> config { get; set; }
		private string plugin_url = "http://localhost:8099/service";

		public File? retrieve_plugin( string plugin_name, string? version = null ) throws Error {
			var params = new HashMap<string,string>();
			params["n"] = plugin_name;
			if ( version != null ) {
				params["b"] = version;
			}
			File? archive_file = retrieve_archive(params);
			if ( archive_file != null ) {
				var temp_directory = unarchive_file(archive_file);
				if ( temp_directory != null ) {
					return temp_directory;
				}
			}
			return null;
		}

		public bool cleanup( File retrieved_plugin ) {
			if ( "tmp-" in retrieved_plugin.get_basename() ) {
				clean_directory(retrieved_plugin);
			}
			return true;
		}

		public ArrayList<PluginResult> search_plugin( string plugin_name ) throws Error {
			var results = new ArrayList<PluginResult>();
			var params = new HashMap<string,string>();
			params["q"] = plugin_name;
			var content = http_get( "search", params );
			if ( content != null ) {
				var parser = new Json.Parser();
				try {
					parser.load_from_data( content, -1 );
				} catch (Error e) {
					Logger.error( "Service unavailable. (%s)", e.message );
					return results;
				}
				var root_object = parser.get_root().get_object();
				foreach ( var plugin_node in root_object.get_array_member("plugins").get_elements() ) {
					var plugin_result = (PluginResult) Json.gobject_deserialize( typeof(PluginResult), plugin_node );
					results.add(plugin_result);
				}
			}
			return results;
		}

		public ArrayList<PluginResult> available_plugins() throws Error {
			return new ArrayList<PluginResult>();
		}

		public ArrayList<PluginResult> check_outdated_plugin( HashMap<string,string> installed_plugins ) {
			return new ArrayList<PluginResult>();
		}

		public PluginManifest? get_manifest( string plugin_name ) {
			var params = new HashMap<string,string>();
			params["n"] = plugin_name;
			var content = http_get( "manifest", params );
			if ( content != null ) {
				var parser = new Json.Parser();
				try {
					parser.load_from_data( content, -1 );
				} catch (Error e) {
					Logger.error( "Service unavailable. (%s)", e.message );
					return null;
				}
				var root = parser.get_root();
				if ( root != null ) {
					return (PluginManifest) Json.gobject_deserialize( typeof(PluginManifest), parser.get_root() );
				}
			}
			return null;
		}

		private string? http_get( string path, HashMap<string,string>? params ) {
			var message = http_get_message( path, params );
			if ( message != null ) {
				return (string) message.response_body.data;
			}
			return null;
		}

		private Soup.Message? http_get_message( string path, HashMap<string,string>? params ) {
			var session = new Soup.SessionSync();
			var message = new Soup.Message( "GET", construct_url( path, params ) );
			session.send_message(message);
			if ( message.status_code == 200 ) {
				return message;
			} else {
				Logger.error( "Received status %u during GET, aborting.".printf( message.status_code ) );
				return null;
			}
		}

		private string construct_url( string path, HashMap<string,string>? params ) {
			string url = ( config["url"] != null ? config["url"] : plugin_url ) + "/" + path + "?cv=1";
			if ( params != null ) {
				foreach ( string param in params.keys ) {
					url = "%s&%s=%s".printf( url, Uri.escape_string( param, null, true ), Uri.escape_string( params[param], null, true ) );
				}
			}
			return url;
		}

		private File? retrieve_archive( HashMap<string,string> params ) {
			Logger.debug("Retrieving archive.");
			var message = http_get_message( "retrieve", params );
			if ( message != null ) {
				try {
					var archive_file = File.new_for_path(
						"%s/%s.tar.gz".printf( Environment.get_tmp_dir(), params["n"] )
					);
					if ( archive_file.query_exists() ) {
						Logger.debug("Deleting old temporary file.");
						archive_file.delete();
					}
					var stream = archive_file.create( FileCreateFlags.REPLACE_DESTINATION );
					size_t bytes;
					stream.write_all( message.response_body.data, out bytes );
					stream.close();
					Logger.debug( "Retrieved %dk.", ( (int) bytes / 1024 ) );
					return archive_file;
				} catch (Error e) {
					Logger.error( "Unable to write archive file: %s", e.message );
				}
			}
			return null;
		}

		private File? unarchive_file( File archive ) {
			string sanitized_name = archive.get_basename().down().replace( " ", "_" ).replace( ".tar.gz", "" );

			// Create temporary directory
			string temp_name = "%s/ambtmp-%s".printf( Environment.get_tmp_dir(), sanitized_name );
			File temp_dir = File.new_for_path(temp_name);
			try {
				temp_dir.make_directory();
			} catch (Error e) {
				Logger.error(e.message);
				return null;
			}
			var current_dir = Environment.get_current_dir();
			if ( Environment.set_current_dir(temp_name) == -1 ) {
				Logger.error( "Unable to change to temp directory: " + temp_name );
				return null;
			}

			// Unarchive file
			string standard_output, standard_error;
			int exit_status;
			try {
				Process.spawn_command_line_sync(
					"tar xf " + archive.get_path(),
					out standard_output,
					out standard_error,
					out exit_status
				);
			} catch (SpawnError se) {
				Logger.error( "Unable to run tar xf: %s".printf( se.message ) );
				clean_directory(temp_dir);
				return null;
			}

			Environment.set_current_dir(current_dir);

			return temp_dir;
		}

		private void clean_directory( File directory ) {
			FileInfo file_info;
			try {
				var enumerator = directory.enumerate_children(
					FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, 0
				);

				while ( ( file_info = enumerator.next_file() ) != null ) {
					if ( file_info.get_file_type() == FileType.DIRECTORY ) {
						clean_directory( File.new_for_path( "%s/%s".printf( directory.get_path(), file_info.get_name() ) ) );
					} else {
						File.new_for_path( "%s/%s".printf( directory.get_path(), file_info.get_name() ) ).delete();
					}
				}
				directory.delete();
			} catch (Error e) {
				Logger.error( "Error while enumerating directory '%s': %s".printf( directory.get_path(), e.message ) );
			}
		}
	}
}
