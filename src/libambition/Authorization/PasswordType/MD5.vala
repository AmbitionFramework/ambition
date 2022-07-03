/*
 * MD5.vala
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

namespace Ambition.Authorization.PasswordType {
	/**
	 * MD5 PasswordType, returning a 32 character hex string.
	 * 
	 * Application configuration can have two options:
	 * 
	 * * pre_salt: Added before the password value when being hashed.
	 * * post_salt: Added after the password value when being hashed.
	 * * iterations: Number of times to hash the resulting string.
	 * 
	 * The same options can be passed at the time of conversion, but they will
	 * override application values, not added to them.
	 */
	public class MD5 : Hashed {
		protected override string hash( string incoming ) {
			return Checksum.compute_for_string( ChecksumType.MD5, incoming );
		}
	}
}
