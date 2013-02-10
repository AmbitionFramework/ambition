/*
 * AlmannaSession.vala
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

using Almanna;
namespace Ambition.Session {
	/**
	 * Abstract session to store Session data via an Almanna entity. Consumers
	 * of this abstract class need to have a table with a session_id integer
	 * field and a session_data string field.
	 */
	public abstract class AlmannaSession : Entity {
		public override string entity_name { owned get { return "session"; } }
		public virtual string session_id { get; set; }
		public virtual string session_data { get; set; }

		public override void register_entity() {
			add_column( new Column<string>.with_name_type( "session_id", "varchar" ) );
			add_column( new Column<string>.with_name_type( "session_data", "varchar" ) );
			try {
				set_primary_key("session_id");
			} catch ( EntityError e ) {
				Logger.warn( "Something is wrong: EntityError while setting primary key: %s".printf( e.message ) );
			}
		}
	}
}