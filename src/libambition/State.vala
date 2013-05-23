/*
 * State.vala
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

namespace Ambition {

	/**
	 * Represent the state of the current request, including request, response,
	 * session, authorization.
	 */
	public class State : Component {
		private Session.Interface _session;
		private Authorization.Authorize _authorization;

		/**
		 * Current session, if available
		 */
		public Session.Interface session {
			get {
				if ( _session == null ) {
					_session = new Session.Interface();
				}
				return _session;
			}
			set { _session = value; }
		}

		/**
		 * Current authorization, if available.
		 */
		public Authorization.Authorize authorization {
			get {
				if ( _authorization == null ) {
					_authorization = new Authorization.Authorize();
				}
				return _authorization;
			}
			set { _authorization = value; }
		}

		/**
		 * Current HTTP Request
		 */
		public Request request { get; set; }

		/**
		 * Current Response
		 */
		public Response response { get; set; }

		/**
		 * Exact timestamp of the start of this request.
		 */
		public DateTime start { get; set; }

		/**
		 * Use the stash in this request.
		 */
		public Stash stash { get; set; default = new Stash(); }

		/**
		 * Current user, if authenticated. NULL if no user present.
		 */
		public Authorization.IUser? user {
			get {
				if ( _authorization != null ) {
					return _authorization.user;
				}
				return null;
			}
		}

		/**
		 * Return true if a user is authenticated
		 */
		public bool has_user {
			get {
				return ( this.user == null ? false : true );
			}
		}

		/**
		 * Logging instance of this request
		 */
		public Ambition.Logger.Unique log;

		/**
		 * Create new State object with a given identifier.
		 */
		public State( string id ) {
			start = new DateTime.now_utc();
			log = new Ambition.Logger.Unique(id);
		}

		/**
		 * Elapsed time since the start of this request.
		 */
		public int64 elapsed() {
			return (new DateTime.now_utc()).difference(start);
		}

		/**
		 * Elapsed time since the start of this request, in milliseconds.
		 */
		public float elapsed_ms() {
			return ((float) elapsed() ) / 1000.0f;
		}

		public void ping() {}

		/**
		 * Shortcut method to authorization.authorize() method.
		 * @param authorizer_name Name of the configured authorizer
		 * @param username String with the given username
		 * @param password String with the given password
		 */
		public bool authorize( string authorizer_name, string username, string password ) {
			return this.authorization.authorize( authorizer_name, username, password );
		}

		/**
		 * Shortcut to remove user and destroy session.
		 */
		public void logout() {
			this.authorization.unauthorize();
			this.session.destroy();
		}
	}
}
