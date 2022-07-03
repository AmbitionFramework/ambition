/*
 * IPasswordType.vala
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
namespace Ambition.Authorization {
	/**
	 * Interface for building a PasswordType.
	 */
	public interface IPasswordType : Object {
		protected abstract HashMap<string,string> config { get; set; }

		/**
		 * Initialize password type with config
		 * @param config Configuration HashMap
		 */
		public abstract void init( HashMap<string,string> config );

		/**
		 * Convert the given password value to the hashed, crypted, or other
		 * type of converted value.
		 * @param password_value Value to convert
		 * @param options Optional HashMap<string,string> of additional params.
		 */
		public abstract string convert( string password_value, HashMap<string,string>? options = null );
	}
}
