/*
 * IStorable.vala
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

namespace Ambition.Session {
	/**
	 * Interface for any class implementing a session store. To use, subclass
	 * Object and then Storable, and implement store, retrieve, and set_config.
	 * While using the provided config is optional, the method is required to
	 * be implemented so other Storables can use it.
	 */
	public interface IStorable : Object {

		/**
		 * Store session data using a given session ID.
		 * @param session_id Generated or passed session ID
		 * @param i Session.Interface instance
		 */
		public abstract void store( string session_id, Interface i );

		/**
		 * Retrieve session data using a given session ID.
		 * @param session_id Generated or passed session ID
		 */
		public abstract Interface? retrieve( string session_id );
	}
}
