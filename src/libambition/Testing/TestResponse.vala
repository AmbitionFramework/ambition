/*
 * TestResponse.vala
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

namespace Ambition.Testing {
	/**
	 * Response from a Helper.mock_request.
	 */
	public class TestResponse : Object {
		private string? _result_content = null;

		/**
		 * State object.
		 */
		public State state { get; set; }

		/**
		 * Request object from State.
		 */
		public Request request {
			get {
				return state.request;
			}
		}

		/**
		 * Response object from State.
		 */
		public Response response {
			get {
				return state.response;
			}
		}

		/**
		 * The rendered content from a response.
		 */
		public string? result_content {
			get {
				if ( _result_content == null ) {
					uint8[] buffer = new uint8[ response.get_body_length() ];
					size_t size;
					try {
						response.get_body_data().read_all( buffer, out size );
						_result_content = (string) buffer;
					} catch (IOError e) {
						Log4Vala.Logger.get_logger("Ambition.Testing.TestResponse").error( "Error reading body data", e );
					}
				}
				return _result_content;
			}
		}


		/**
		 * HTTP response status code matches value.
		 * @param status HTTP status code
		 */
		public bool status_is( int status ) {
			return ( response.status == status );
		}

		/**
		 * HTTP response status code does not match value.
		 * @param status HTTP status code
		 */
		public bool status_isnt( int status ) {
			return ( !status_is(status) );
		}

		/**
		 * Header exists and matches value.
		 * @param header_name Header name (ex: X-Powered-By)
		 * @param header_value Header value (ex: Ambition)
		 */
		public bool header_is( string header_name, string header_value ) {
			return ( response.headers.has_key(header_name) && response.headers[header_name] == header_value );
		}

		/**
		 * Header exists and does not match value, or header does not exist.
		 * @param header_name Header name (ex: X-Powered-By)
		 * @param header_value Header value (ex: Unicorns)
		 */
		public bool header_isnt( string header_name, string header_value ) {
			return ( !header_is( header_name, header_value ) );
		}

		/**
		 * Content Type matches value.
		 * @param content_type Content type string.
		 */
		public bool content_type_is( string content_type ) {
			return ( response.content_type == content_type );
		}

		/**
		 * Content Type does not match value.
		 * @param content_type Content type string.
		 */
		public bool content_type_isnt( string content_type ) {
			 return ( !content_type_is(content_type) );
		}

		/**
		 * Content Type contains value (case insensitive).
		 * @param content_type Content type string.
		 */
		public bool content_type_like( string content_type ) {
			return ( response.content_type.down().contains(content_type.down()) );
		}

		/**
		 * Content Type does not contain value (case insensitive).
		 * @param content_type Content type string.
		 */
		public bool content_type_unlike( string content_type ) {
			return( !content_type_like(content_type) );
		}

		/**
		 * Result content matches value.
		 * @param content Content string.
		 */
		public bool content_is( string content ) {
			return ( result_content == content );
		}

		/**
		 * Result content does not match value.
		 * @param content Content string.
		 */
		public bool content_isnt( string content ) {
			return ( !content_is(content) );
		}

		/**
		 * Result content contains value (case sensitive).
		 * @param content Content string.
		 */
		public bool content_like( string content ) {
			return ( result_content.contains(content) );
		}

		/**
		 * Result content does not contain value (case sensitive).
		 * @param content Content string.
		 */
		public void content_unlike( string content ) {
			assert( result_content.contains(content) == false );
		}

		/**
		 * Assert HTTP response status code matches value.
		 * @param status HTTP status code
		 */
		[Deprecated( since = "0.2", replacement = "status_is" )]
		public void assert_status_is( int status ) {
			assert( status_is(status) );
		}

		/**
		 * Assert HTTP response status code does not match value.
		 * @param status HTTP status code
		 */
		[Deprecated( since = "0.2", replacement = "status_isnt" )]
		public void assert_status_isnt( int status ) {
			assert( status_isnt(status) );
		}

		/**
		 * Assert header exists and matches value.
		 * @param header_name Header name (ex: X-Powered-By)
		 * @param header_value Header value (ex: Ambition)
		 */
		[Deprecated( since = "0.2", replacement = "header_is" )]
		public void assert_header_is( string header_name, string header_value ) {
			assert( header_is( header_name, header_value ) );
		}

		/**
		 * Assert header exists and does not match value, or header does not exist.
		 * @param header_name Header name (ex: X-Powered-By)
		 * @param header_value Header value (ex: Unicorns)
		 */
		[Deprecated( since = "0.2", replacement = "header_isnt" )]
		public void assert_header_isnt( string header_name, string header_value ) {
			assert( header_isnt( header_name, header_value ) );
		}

		/**
		 * Assert Content Type matches value.
		 * @param content_type Content type string.
		 */
		[Deprecated( since = "0.2", replacement = "content_type_is" )]
		public void assert_content_type_is( string content_type ) {
			assert( content_type_is(content_type) );
		}

		/**
		 * Assert Content Type does not match value.
		 * @param content_type Content type string.
		 */
		[Deprecated( since = "0.2", replacement = "content_type_isnt" )]
		public void assert_content_type_isnt( string content_type ) {
			assert( content_type_isnt(content_type) );
		}

		/**
		 * Assert Content Type contains value (case insensitive).
		 * @param content_type Content type string.
		 */
		[Deprecated( since = "0.2", replacement = "content_type_like" )]
		public void assert_content_type_like( string content_type ) {
			assert( content_type_like(content_type) );
		}

		/**
		 * Assert Content Type does not contain value (case insensitive).
		 * @param content_type Content type string.
		 */
		[Deprecated( since = "0.2", replacement = "content_type_unlike" )]
		public void assert_content_type_unlike( string content_type ) {
			assert( content_type_unlike(content_type) );
		}

		/**
		 * Assert result content matches value.
		 * @param content Content string.
		 */
		[Deprecated( since = "0.2", replacement = "content_is" )]
		public void assert_content_is( string content ) {
			assert( content_is(content) );
		}

		/**
		 * Assert result content does not match value.
		 * @param content Content string.
		 */
		[Deprecated( since = "0.2", replacement = "content_isnt" )]
		public void assert_content_isnt( string content ) {
			assert( content_isnt(content) );
		}

		/**
		 * Assert result content contains value (case sensitive).
		 * @param content Content string.
		 */
		[Deprecated( since = "0.2", replacement = "content_like" )]
		public void assert_content_like( string content ) {
			assert( content_like(content) );
		}

		/**
		 * Assert result content does not contain value (case sensitive).
		 * @param content Content string.
		 */
		[Deprecated( since = "0.2", replacement = "content_unlike" )]
		public void assert_content_unlike( string content ) {
			assert( result_content.contains(content) == false );
		}
	}
}