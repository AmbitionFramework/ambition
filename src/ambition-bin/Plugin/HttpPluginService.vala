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

		public File? retrieve_plugin( string plugin_name ) throws Error {
			return null;
		}

		public ArrayList<PluginResult> search_plugin( string plugin_name ) throws Error {
			return new ArrayList<PluginResult>();
		}

		public ArrayList<PluginResult> available_plugins() throws Error {
			return new ArrayList<PluginResult>();
		}

		public ArrayList<PluginResult> check_outdated_plugin( HashMap<string,string> installed_plugins ) {
			return new ArrayList<PluginResult>();
		}

		public PluginManifest? get_manifest( string plugin_name ) {
			return null;
		}

		private File? retrieve( string plugin_name, string? version = null ) {
			return null;
		}

		private string? http_get( string path, HashMap<string,string>? params ) {
			var session = new Soup.SessionSync();
			var message = new Soup.Message( "GET", construct_url( path, params ) );
			session.send_message(message);
			if ( message.status_code == 200 ) {
				return (string) message.response_body.data;
			} else {
				Logger.error( "Received status %u".printf( message.status_code ) );
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
