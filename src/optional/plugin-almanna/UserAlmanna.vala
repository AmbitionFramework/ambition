/*
 * UserAlmanna.vala
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
using Almanna;
namespace Ambition.Authorization.User {
	/**
	 * Represents a user in an Almanna entity.
	 */
	public class Almanna : Object,IUser {
		private Entity? _entity = null;
		protected HashMap<string,string> config { get; set; }
		public string authorizer_name { get; set; default = "almanna"; }
		public int? id { get; set; }
		public string? username { get; set; }

		public Almanna.with_params( HashMap<string,string> config, int id, string username ) {
			this.config = config;
			this.id = id;
			this.username = username;
		}

		public Almanna.with_config( HashMap<string,string> config ) {
			this.config = config;
		}

		/**
		 * Return the entity associated with this user.
		 */
		public Object? get_object() {
			// Look up entity if it hasn't been loaded yet
			if ( _entity == null && id != null ) {
				try {
					string entity_type = config["entity_type"];
					if ( "." in entity_type ) {
						entity_type = entity_type.replace( ".", "" );
					}
					Entity e = Repo.get_entity( Type.from_name(entity_type) );
					if ( e != null ) {
						_entity = e.search().lookup(id);
					}
				} catch ( SearchError se ) {
					Logger.error( "Search error: %d %s".printf( se.code, se.message ) );
					return null;
				}
			}
			return _entity;
		}
	}
}
