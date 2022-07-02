/*
 * Request.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2016 Sensical, Inc.
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
	 * Represents the HTTP request. This is generated by the Ambition engine and
	 * passed to a given controller and method.
	 */
	public class Request : Object {
		private string _arguments;
		private string _uri;
		private string _base_uri;

		/**
		 * Provides all cookies set for this request.
		 */
		public HashMap<string,Cookie> cookies { get; set; default = new HashMap<string,Cookie>(); }

		/**
		 * All query and body parameters for this request.
		 */
		public HashMap<string,string> params { get; set; }

		/**
		 * All incoming headers in this request.
		 */
		public HashMap<string,string> headers { get; set; }

		/**
		 * HTTP request method.
		 */
		public HttpMethod method { get; set; }

		/**
		 * Request content type.
		 */
		public string? content_type { get; set; }

		/**
		 * Remote IP address connecting to this server.
		 */
		public string ip { get; set; }

		/**
		 * Request URI/URL.
		 */
		public string uri { get { return _uri; } }

		/**
		 * Base URI/URL.
		 */
		public string base_uri {
			get { 
				string port_addon = "";
				if (
					! host.contains(":")
					&& (
						( protocol == "http" && port != 80 )
						|| ( protocol == "https" && port != 443 )
					)
				) {
					port_addon = ":%d".printf(port);
				}
				_base_uri = "%s://%s%s".printf( protocol, host, port_addon );
				return _base_uri;
			}
		}

		/**
		 * Protocol being used to access this resource, according to the best
		 * guess of the engine or framework. Some proxies and engines do not
		 * provide this information accurately.
		 */
		public string protocol { get; private set; }

		/**
		 * Hostname of the server.
		 */
		public string host { get; private set; }

		/**
		 * Port being requested.
		 */
		public int port { get; private set; }

		/**
		 * Path of the request URL.
		 */
		public string path { get; set; }

		/**
		 * User agent/browser string.
		 */
		public string user_agent { get; set; }

		/**
		 * Raw, unparsed request body. Note that if the content type is
		 * multipart/form-data, this will only contain the form-data portion
		 * of the incoming MIME document.
		 */
		public uint8[] request_body { get; set; }

		/**
		 * Retrieve the list of URL captures, if requested.
		 */
		public string[] captures { get; set; default = {}; }

		public HashMap<string,RequestFile> files { get; set; default = new HashMap<string,RequestFile>(); }

		/**
		 * Retrieve named captures, if requested.
		 */
		public HashMap<string,string> named_captures { get; set; default = new HashMap<string,string>(); }

		public string arguments_string {
			get {
				return _arguments;
			}
			set {
				_arguments = value;
				if ( _arguments.has_prefix("/") ) {
					_arguments = _arguments.substring(1);
				}
				if ( _arguments.has_suffix("/") ) {
					_arguments = _arguments.substring( 0, _arguments.length - 1 );
				}
			}
		}

		~Request() {
			if ( files.size > 0 ) {
				bool keep_files = false;
				if ( Config.get_instance().config_hash.size > 0 ) {
					keep_files = Config.lookup_bool("app.keep_files");
				}
				foreach ( var file in files.keys ) {
					if ( !keep_files ) {
						files[file].file.@delete();
					}
				}
			}
		}
		
		/**
		 * Used primarily by engines, converts a query string to a HashMap
		 * suitable for storage as parameters.
		 */
		public static HashMap<string,string> params_from_string( string query ) {
			var h = new HashMap<string,string>();
			// Turn semi-colons into ampersands before splitting
			foreach ( string s in query.replace( ";", "&" ).split("&") ) {
				int eq = s.index_of("=");
				if ( eq > 0 ) {
					string k = Uri.unescape_string( s.substring( 0, eq ) );
					string v = Uri.unescape_string( s.substring(eq + 1).replace( "+", " " ) );
					if ( h.has_key(k) ) {
						h[k] = string.join( ",", h[k], v );
					} else {
						h[k] = v;
					}
				} else {
					string k = Uri.unescape_string(s);
					string v = "";
					if ( ! h.has_key(k) ) {
						h[k] = v;
					}
				}
			}
			return h;
		}
		
		/**
		 * Set the URI given the components of a URL.
		 * @param protocol HTTP protocol
		 * @param host HTTP hostname
		 * @param raw_path Path of the URL
		 * @param clean_path Entity-stripped path
		 */
		public void set_uri( string protocol, string host, string raw_path, string clean_path ) {
			_uri = "%s://%s%s".printf(protocol, host, raw_path);
			this.protocol = protocol;
			this.host = host;
			var colon = host.index_of(":");
			if (colon != -1) {
				this.port = int.parse( host[ colon + 1 : host.length ] );
			} else {
				if ( this.protocol == "https" ) {
					this.port = 443;
				} else {
					this.port = 80;
				}
			}
			this.path = clean_path;
		}

		public void initialize(
				HttpMethod method, string ip, string protocol, 
				string host, string raw_path, string clean_path, 
				HashMap<string,string> params, HashMap<string,string> headers,
				string? content_type = null
			) {
			set_uri( protocol, host, raw_path, clean_path );
			this.method  = method;
			this.ip      = ip;
			this.params  = params;
			this.headers = headers;
			this.content_type = content_type;
		}

		/**
		 * Retrieve a request parameter by name, null if unavailable.
		 */
		public string? param( string key ) {
			return params.get(key);
		}

		/**
		 * Retrieve a request header by name, null if unavailable.
		 */
		public string? header( string key ) {
			return headers.get(key);
		}

		/**
		 * Retrieve the list of URL arguments, if supported by dispatch type.
		 */
		public string[]? arguments() {
			if ( this.arguments_string != null ) {
				return this.arguments_string.split("/");
			}
			return null;
		}

		/**
		 * Retrieve a URL capture by name, null if unavailable.
		 */
		public string? get_capture( string capture_name ) {
			return this.named_captures[capture_name];
		}

		/**
		 * Retrieve a URL capture by name as an int, -1 if unavailable.
		 */
		public int get_capture_int( string capture_name ) {
			var captured = this.named_captures[capture_name];
			if ( captured == null ) {
				return -1;
			}
			return int.parse(captured);
		}

		/**
		 * Retrieve a URL capture by index, null if unavailable.
		 */
		public string? get_capture_index( int capture_index ) {
			return this.captures[capture_index];
		}

		/**
		 * Retrieve a URL capture by index as an int, -1 if unavailable.
		 */
		public int get_capture_index_int( int capture_index ) {
			var captured = this.captures[capture_index];
			if ( captured == null ) {
				return -1;
			}
			return int.parse(captured);
		}

		/**
		 * Retrieve a request cookie by name, null if unavailable.
		 */
		public Cookie? get_cookie( string name ) {
			return cookies.get(name);
		}

		/**
		 * Add a cookie to the list of request cookies.
		 */
		public void set_cookie( Cookie cookie ) {
			cookies.set( cookie.name, cookie );
		}

	}
}
