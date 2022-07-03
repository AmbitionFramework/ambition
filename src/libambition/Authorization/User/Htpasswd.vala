/*
 * Htpasswd.vala
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
namespace Ambition.Authorization.User {
	/**
	 * Represents a user in a htpasswd file.
	 */
	public class Htpasswd : Object,IUser {
		public string authorizer_name { get; set; default = "Htpasswd"; }
		public int id { get; set; default = 0; }
		public string? username { get; set; }

		public Htpasswd.with_params( int id, string username ) {
			this.id = id;
			this.username = username;
		}

		public Object? get_object() {
			return null;
		}
	}
}
