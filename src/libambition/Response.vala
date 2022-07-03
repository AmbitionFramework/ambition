/*
 * Response.vala
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

using Gee;

namespace Ambition {
	/**
	 * Represents the HTTP response after a request. This is generated by the
	 * Ambition engine and passed to a given controller and method.
	 */
	public class Response : Object {
		private bool _done = false;

		/**
		 * Additional dynamic headers to be sent in the HTTP response.
		 */
		public HashMap<string,string> headers { get; set; default = new HashMap<string,string>(); }

		/**
		 * Additional dynamic cookies to be sent in the HTTP response.
		 */
		public HashMap<string,Cookie> cookies { get; set; default = new HashMap<string,Cookie>(); }

		/**
		 * HTTP status code, defaulting to 200.
		 */
		public int status { get; set; default = 200; }

		/**
		 * Set response body to the provided InputStream. If the provided value
		 * is not null, Ambition will not look for an array or string.
		 */
		public InputStream body_stream { get; set; }

		/**
		 * Set response body to a uint8 array. If body_stream is null, and this
		 * value is not null, Ambition will not look for a string.
		 */
		public uint8[]? body_array { get; set; }

		/**
		 * Set response body to a string. If body_stream and body_array are not
		 * null, the provided body will be set.
		 */
		public string body { get; set; }

		/**
		 * If body is provided as an InputStream, length is not calculated
		 * before the request, and must be set manually.
		 */
		public int64 body_stream_length { get; set; }

		/**
		 * Content type of the response, defaults to "text/html".
		 */
		public string? content_type { get; set; default = "text/html"; }

		/**
		 * Get an existing response cookie by name.
		 * @param name Name of the cookie.
		 */
		public Cookie get_cookie( string name ) {
			return cookies.get(name);
		}

		/**
		 * Create or replace a response cookie.
		 * @param cookie Valid Cookie object.
		 */
		public void set_cookie( Cookie cookie ) {
			cookies.set( cookie.name, cookie );
		}

		/**
		 * Retrieve an existing header by name.
		 * @param key Header name
		 */
		public string header( string key ) {
			return headers.get(key);
		}

		/**
		 * Set a response header.
		 * @param key Header name
		 * @param val Content of header.
		 */
		public void set_header( string key, string val ) {
			headers.set( key, val );
		}

		/**
		 * Set response to redirect to another page
		 * @param url URL to redirect to
		 */
		public void redirect( string url ) {
			this.status = 302;
			this.body = "";
			this.set_header( "Location", url );
		}

		/**
		 * Halt execution after the current method.
		 */
		public void done() {
			this._done = true;
		}

		/**
		 * Determine if done() been requested.
		 */
		public bool is_done() {
			return this._done;
		}

		/**
		 * Get body data universally, whether body is a stream, array, or
		 * string.
		 * @return InputStream
		 */
		public InputStream? get_body_data() {
			if ( this.body_stream != null ) {
				return this.body_stream;
			} else if ( this.body_array != null && this.body_array.length > 0 ) {
				return new MemoryInputStream.from_data( this.body_array, GLib.g_free );
			} else if ( this.body != null ) {
				return new MemoryInputStream.from_data( this.body.data, GLib.g_free );
			}
			return null;
		}

		/**
		 * Get body data length universally, whether body is a stream, array, or
		 * string.
		 * @return int64
		 */
		public int64 get_body_length() {
			if ( this.body_stream != null ) {
				return this.body_stream_length;
			} else if ( this.body_array != null && this.body_array.length > 0 ) {
				return this.body_array.length;
			} else if ( this.body != null ) {
				return this.body.length;
			}
			return 0;
		}
	}
}
