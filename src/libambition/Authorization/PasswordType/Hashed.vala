/*
 * Hashed.vala
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
namespace Ambition.Authorization.PasswordType {
	/**
	 * Hashed PasswordType base class, not to be used by itself.
	 * 
	 * Application configuration can have two options:
	 * * pre_salt: Added before the password value when being hashed.
	 * * post_salt: Added after the password value when being hashed.
	 * * iterations: Number of times to hash the resulting string.
	 * 
	 * The same options can be passed at the time of conversion, but they will
	 * override application values, not added to them.
	 */
	public abstract class Hashed : Object,IPasswordType {
		protected HashMap<string,string> config { get; set; }

		public void init( HashMap<string,string> config ) {
			this.config = config;
		}

		public string convert( string password_value, HashMap<string,string>? options = null ) {
			var buffer = new StringBuilder();

			bool has_options = ( options != null );

			// Pre-salt
			if ( has_options && options["pre_salt"] != null ) {
				buffer.append( options["pre_salt"] );
			} else if ( config["pre_salt"] != null ) {
				buffer.append( config["pre_salt"] );
			}

			buffer.append(password_value);

			// Post-salt
			if ( has_options && options["post_salt"] != null ) {
				buffer.append( options["post_salt"] );
			} else if ( config["post_salt"] != null ) {
				buffer.append( config["post_salt"] );
			}

			// Iterations
			int iterations = 1;
			if ( has_options && options["iterations"] != null ) {
				iterations = int.parse( options["iterations"] );
			} else if ( config["iterations"] != null ) {
				iterations = int.parse( config["iterations"] );
			}
			string result = buffer.str;
			for ( int index = 0; index < iterations; index++ ) {
				result = hash(result);
			}

			return result;
		}

		protected abstract string hash( string incoming );
	}
}
