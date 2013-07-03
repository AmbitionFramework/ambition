/*
 * IUser.vala
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
namespace Ambition.Authorization {
	/**
	 * Interface for building a user object from a given authorizer.
	 */
	public interface IUser : Object {

		/**
		 * Name/type of user object
		 */
		public abstract string authorizer_name { get; set; }

		/**
		 * Return ID for given user
		 */
		public abstract int id { get; set; default = 0; }

		/**
		 * Return ID for given user
		 */
		public abstract string? username { get; set; }

		/**
		 * If there is an associated object for this user, return it.
		 */
		public abstract Object? get_object();

		/**
		 * Serialize current user object for loading later. The default
		 * implementation handles the serialization of id and username.
		 * @return Serialized string
		 */
		public string serialize() {
			return "%d¬%s".printf( id, username );
		}

		/**
		 * Fix object from serialized data. The default implementation handles
		 * deserialization of id and username.
		 * @param serialized Serialized data
		 */
		public void deserialize( string serialized ) {
			string id = serialized.substring( 0, serialized.index_of("¬") );
			this.id = int.parse(id);
			this.username = serialized.substring( serialized.index_of("¬") + 2 );
		}
	}
}
