/*
 * IUtility.vala
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

namespace Ambition.Utility {

	/**
	 * Interface for defining a new Ambition Shell plugin.
	 */
	public interface IUtility : Object {
		/**
		 * Name of the plugin.
		 */
		public abstract string name { get; }

		/**
		 * Method called when a plugin is first created, to allow a plugin
		 * to initialize any default values or instantiate other components.
		 */
		public abstract void register_utility();

		/**
		 * Method that receives a command and arguments. Return an exit code.
		 * @param args Command and arguments
		 */
		public abstract int receive_command( string[] args );

		/**
		 * Returns a string containing help text. Be sure to use wrap_string().
		 */
		public abstract string help();
	}
}
