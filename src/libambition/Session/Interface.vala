/*
 * Interface.vala
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

namespace Ambition.Session {
	/**
	 * Represents session functionality on top of a session storage engine.
	 */
	public class Interface : Object {
		private static const string VER = "as1";
		private static const string HEAD_SEP = "ƍ|";
		private static const string RECORD_SEP = "ƍƆ|/";
		private static const string VAL_SEP = "Ɔ|ƕ";

		public HashMap<string,string> string_params;

		public string session_id { get; private set; }
		public string id {
			get { return session_id; }
		}
		public bool has_data {
			get { return string_params.size > 0; }
		}

		/**
		 * Create a Interface object 
		 * @param session_id Optional stored session identifier
		 */
		public Interface( string? session_id = null ) {
			this.string_params = new HashMap<string,string>();
			if ( session_id == null ) {
				generate_session_id();
			} else {
				this._session_id = session_id;
			}
		}

		/**
		 * Create a Interface object from a serialized value
		 * @param session_id Stored session identifier
		 * @param serialized Text of serialized object
		 */
		public Interface.from_serialized( string session_id, string serialized ) {
			this(session_id);
			string decoded = (string) Base64.decode(serialized);
			string[] signature = decoded.split(HEAD_SEP);
			if ( signature[0] != VER ) {
				Log4Vala.Logger.get_logger("Ambition.Session.Interface").warn("Cannot deserialize session");
				return;
			} else {
				string[] pairs = signature[1].split(RECORD_SEP);
				foreach ( string pair in pairs ) {
					if ( pair != null && pair.length > 1 ) {
						string[] d_pair = pair.split(VAL_SEP);
						string_params.set( d_pair[0], d_pair[1] );
					}
				}
			}
		}

		/**
		 * Generate session identifier
		 */
		public void generate_session_id() {
			string seed = Random.next_int().to_string() + new DateTime.now_local().to_unix().to_string();
			this._session_id = Checksum.compute_for_string( ChecksumType.SHA1, seed );
		}

		/**
		 * Destroy this session. This does not remove the session from the
		 * session store.
		 */
		public void destroy() {
			this.string_params = new HashMap<string,string>();
			generate_session_id();
		}

		/**
		 * Set a session value
		 * @param key Lookup key
		 * @param value Value for key
		 */
		public void set_value( string key, string value ) {
			string_params.set( key, value );
		}

		/**
		 * Get a session value
		 * @param key Lookup key
		 */
		public string? get_value( string key ) {
			return string_params.get(key);
		}

		/**
		 * Check if a session key exists.
		 * @param key Lookup key
		 */
		public bool has_value( string key ) {
			return string_params.has_key(key);
		}

		/**
		 * Delete a session value, optionally return the value that existed
		 * before deletion.
		 * @param key Lookup key
		 */
		public string? delete_value( string key ) {
			string? val = get_value(key);
			string_params.unset(key);
			return val;
		}

		/**
		 * Serialize current session to JSON
		 * @return string containing JSON data stream
		 */
		public string serialize() {
			var sb = new StringBuilder();
			sb.append(VER);
			sb.append(HEAD_SEP);
			foreach ( string k in string_params.keys ) {
				sb.append(RECORD_SEP);
				sb.append(k);
				sb.append(VAL_SEP);
				sb.append( string_params.get(k) );
			}
			return Base64.encode( sb.str.data );
		}
	}
}
