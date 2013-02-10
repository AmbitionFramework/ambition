/*
 * StorableMemory.vala
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
	 * Implementation to store sessions in memory in the dumbest way possible.
	 * This thing will keep growing and growing, and is designed as a basic
	 * example or to test functionality without requiring an external
	 * dependency.
	 */
	public class StorableMemory : Object,IStorable {
		private HashMap<string,Interface> sessions { get; set; default = new HashMap<string,Interface>(); }

		public void store( string session_id, Interface i ) {
			sessions.set( session_id, i );
		}

		public Interface? retrieve( string session_id ) {
			if ( sessions.has_key(session_id) ) {
				return sessions.get(session_id);
			}

			Logger.info("Session not found");
			return null;
		}
	}
}