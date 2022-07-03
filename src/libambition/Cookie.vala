/*
 * Cookie.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
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

namespace Ambition {
	/**
	 * Represents an HTTP cookie.
	 */
	public class Cookie : Object {
		private int _max_age = 0;

		/**
		 * Name of the cookie.
		 */
		public string name { get; set; }
		/**
		 * Content of the cookie.
		 */
		public string value { get; set; default = ""; }
		/**
		 * Expiration date as a HTTP formatted date, but normally will be set
		 * automatically with max_age.
		 */
		public string? expires { get; set; }
		/**
		 * Expiration as a relative value in seconds. This can be set at the
		 * same time as expires, and browsers will ignore expires if they
		 * support max-age.
		 */
		public int max_age {
			get {
				return _max_age;
			}
			set {
				if ( value == 0 ) {
					expires = null;
				} else {
					var newtime = new DateTime.now_utc().add_seconds(value);
					expires = newtime.format("%a, %d %b %Y %H:%M:%S GMT");
				}
				_max_age = value;
			}
		}
		/**
		 * Partial or full domain name for which this cookie is valid.
		 */
		public string domain { get; set; }
		/**
		 * Partial or full path for which this cookie is valid. Defaults to "/".
		 */
		public string path { get; set; default = "/"; }
		/**
		 * True if this cookie is only valid when accessed over HTTPS.
		 */
		public bool secure { get; set; default = false; }
		/**
		 * True if this cookie is only set for HTTP requests, and not to be read
		 * by on-page JavaScript.
		 */
		public bool http_only { get; set; default = false; }
		
		/**
		 * Return true if this instance has all the required fields for
		 * rendering -- name, value, and expires or max_age.
		 */
		public bool is_valid() {
			if ( name != null && value != null && ( expires != null || max_age > 0 ) ) {
				return true;
			}
			return false;
		}

		/**
		 * Render this instance per RFC 2965 and/or 6265.
		 */
		public string? render() {
			if ( !is_valid() ) {
				return null;
			}
			var cookie_string = new StringBuilder();
			cookie_string.append( "%s=%s; Path=%s".printf( name, value, path ) );
			if ( expires != null ) {
				cookie_string.append( "; Expires=%s".printf(expires) );
			}
			if ( max_age > 0 ) {
				cookie_string.append( "; Max-Age=%d".printf(max_age) );
			}
			if ( domain != null ) {
				cookie_string.append( "; Domain=%s".printf(domain) );
			}
			if (secure) {
				cookie_string.append("; Secure");
			}
			if (http_only) {
				cookie_string.append("; HttpOnly");
			}

			return cookie_string.str;
		}
	}
}
