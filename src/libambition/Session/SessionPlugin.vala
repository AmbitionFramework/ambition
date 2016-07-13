/*
 * SessionPlugin.vala
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
using Ambition.PluginSupport;

namespace Ambition.Session {
	/**
	 * Provides Session support to an Ambition application.
	 */
	public class SessionPlugin : Object,IPlugin {
		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.Session.SessionPlugin");
		public string name { get { return "Session"; } }
		private IStorable session_store { get; set; }

		public static Type init_plugin() {
			return typeof(SessionPlugin);
		}

		public void register_plugin() {
			var tmp = typeof(StorableFile);
			if ( tmp == 0 ) {}

			// Try to get store
			string store = Config.lookup("session.store");
			if ( store != null ) {
				string store_type = "AmbitionSession%s".printf(store);
				Type t = Type.from_name(store_type);
				if ( t > 0 ) {
					this.session_store = (IStorable) Object.new(t);
				} else {
					logger.error( "Invalid session.store specified: %s".printf(store) );
					return;
				}
			}
		}

		public void on_request_dispatch( State state ) {
			initialize_session(state);
			if ( state.session != null && state.session.session_id != null ) {
				logger.debug( "Found session %s".printf( state.session.session_id ) );
			}
		}

		public void on_request_end( State state ) {
			if ( session_store != null && state.response.status >= 200 && state.response.status < 400 ) {
				serialize_session(state);
			}
		}

		/**
		 * Called while parsing the request, initializes the session if a cookie
		 * exists, is valid, and is in storage.
		 * @param state State
		 */
		private void initialize_session( State state ) {
			if ( session_store != null ) {
				string session_name = Config.lookup_with_default(
					"session.name", "session_id"
				);
				var cookie = state.request.get_cookie(session_name);
				if ( cookie != null ) {
					var session = session_store.retrieve( cookie.value );
					if ( session != null ) {
						state.session = session;

						// Deserialize user from session
						var user_string = session.get_value("_user");
						if ( user_string != null ) {
							state.authorization.authorize_previous(
								session.get_value("_user_type"),
								session.get_value("_user")
							);
						}
					} else {
						state.session = new Session.Interface();
					}
				}
			}
		}

		/**
		 * Called after rendering output, serializes the current session to
		 * the active Storage, if session is not null and sessions are active.
		 * @param state State
		 */
		private void serialize_session( State state ) {
			if ( state.session != null ) {
				// Serialize user to session
				if ( state.user != null ) {
					state.session.set_value( "_user", state.user.serialize() );
					state.session.set_value( "_user_type", state.user.authorizer_name );
				}

				if ( state.session.id != null ) {
					// flush session
					session_store.store( state.session.id, state.session );

					// Create session cookie
					generate_session_cookie(state);
				}
			}
		}

		/**
		 * Generate the session cookie.
		 * @param state State
		 */
		private void generate_session_cookie( State state ) {
			string session_name = Config.lookup_with_default(
				"session.name", "session_id"
			);
			int? expires = Config.lookup_int("session.expires");
			if ( expires == null ) {
				expires = 3600;
			}
			var c = new Cookie();
			c.name = session_name;
			c.value = state.session.id;
			c.max_age = expires;
			c.render();
			state.response.set_cookie(c);
		}
	}
}
