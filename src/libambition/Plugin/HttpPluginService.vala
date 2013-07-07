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
			return null;
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
			var session = new Soup.SessionSync();
			var message = new Soup.Message( "GET", construct_url( path, params ) );
			session.send_message(message);
			if ( message.status_code == 200 ) {
				return (string) message.response_body.data;
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
	}
}
