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
		private string plugin_url = "http://plugins.ambitionframework.org/service";

		public HttpPluginService() {
			string? url_override = Environment.get_variable("AMBITION_PLUGIN_URL");
			if ( url_override != null ) {
				plugin_url = url_override;
			}
		}

		public File? retrieve_plugin( string plugin_name, string? version = null ) throws Error {
			var params = new HashMap<string,string>();
			params["n"] = plugin_name;
			if ( version != null ) {
				params["b"] = version;
			}
			File? archive_file = retrieve_archive(params);
			if ( archive_file == null ) {
				return null;
			}
			var temp_directory = unarchive_file(archive_file);
			if ( temp_directory == null ) {
				return null;
			}
			var plugin_directory = build_plugin(temp_directory);
			cleanup(temp_directory);
			return plugin_directory;
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
			var results = new ArrayList<PluginResult>();
			if ( installed_plugins.size == 0 ) {
				return results;
			}

			// Generate JSON request from list of plugins
			var params = new HashMap<string,string>();

			var array = new Json.Array();
			foreach ( string plugin_name in installed_plugins.keys ) {
				var plugin_object = new Json.Object();
				plugin_object.set_string_member( "name", plugin_name );
				plugin_object.set_string_member( "version", installed_plugins[plugin_name] );
				array.add_object_element(plugin_object);
			}
			var master_object = new Json.Object();
			master_object.set_array_member( "plugins", array );
			var node = new Json.Node( Json.NodeType.OBJECT );
			node.set_object(master_object);
			var generator = new Json.Generator();
			generator.root = node;

			params["l"] = generator.to_data(null);

			var content = http_get( "versions", params );
			if ( content != null ) {
				var parser = new Json.Parser();
				try {
					parser.load_from_data( content, -1 );
				} catch (Error e) {
					Logger.error( "Service unavailable. (%s)", e.message );
					return results;
				}
				if ( parser.get_root() == null ) {
					Logger.error( "Service unavailable. (Invalid response)" );
					return results;
				}
				var root_object = parser.get_root().get_object();
				if ( root_object.has_member("error") && root_object.get_string_member("error").length > 0 ) {
					Logger.error( "Error: %s", root_object.get_string_member("error") );
					return results;
				}
				foreach ( var plugin_node in root_object.get_array_member("plugins").get_elements() ) {
					var plugin_result = (PluginResult) Json.gobject_deserialize( typeof(PluginResult), plugin_node );
					results.add(plugin_result);
				}
			}
			return results;
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
			message.request_headers.append( "Accept", "application/json" );
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

		private File? build_plugin( File temp_directory ) {
			var current_dir = Environment.get_current_dir();
			
			// Create deploy directory
			string temp_name = "%s/ambtmp-deploy".printf( Environment.get_tmp_dir() );
			File deploy_dir;
			try {
				deploy_dir = File.new_for_path(temp_name);
				if ( deploy_dir.make_directory() == false ) {
					Logger.error( "Unable to create deploy directory: %s", deploy_dir.get_path() );
					return null;
				}
			} catch (Error e) {
				Logger.error( "Unable to create build directory" );
				return null;
			}

			// Create build directory
			File build_dir;
			try {
				build_dir = File.new_for_path( "%s/%s".printf( temp_directory.get_path(), "build" ) );
				if ( build_dir.make_directory() == false ) {
					Logger.error( "Unable to create build directory: %s", build_dir.get_path() );
					return null;
				}
			} catch (Error e) {
				Logger.error( "Unable to create build directory" );
				return null;
			}
			Environment.set_current_dir( build_dir.get_path() );

			// Run cmake
			string standard_output, standard_error;
			int exit_status;
			try {
				Process.spawn_command_line_sync(
					"cmake -DCMAKE_INSTALL_PREFIX='%s' ..".printf( deploy_dir.get_path() ),
					out standard_output,
					out standard_error,
					out exit_status
				);
			} catch (SpawnError se) {
				Logger.error( "Unable to run cmake: %s".printf( se.message ) );
				clean_directory(build_dir);
				return null;
			}
			if ( exit_status != 0 ) {
				Logger.error( "Error during cmake:" );
				stdout.printf(standard_output);
				stderr.printf(standard_error);
				return null;
			}

			// make
			try {
				Process.spawn_command_line_sync(
					"make",
					out standard_output,
					out standard_error,
					out exit_status
				);
			} catch (SpawnError se) {
				Logger.error( "Unable to run make: %s".printf( se.message ) );
				clean_directory(build_dir);
				return null;
			}
			if ( exit_status != 0 ) {
				Logger.error( "Error during make:" );
				stdout.printf(standard_output);
				stderr.printf(standard_error);
				return null;
			}

			// make install
			try {
				Process.spawn_command_line_sync(
					"make install",
					out standard_output,
					out standard_error,
					out exit_status
				);
			} catch (SpawnError se) {
				Logger.error( "Unable to run make install: %s".printf( se.message ) );
				clean_directory(build_dir);
				return null;
			}
			if ( exit_status != 0 ) {
				Logger.error( "Error during make install:" );
				stdout.printf(standard_output);
				stderr.printf(standard_error);
				return null;
			}

			Environment.set_current_dir(current_dir);

			return deploy_dir;
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
