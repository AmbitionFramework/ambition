/*
 * StorableAlmanna.vala
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
namespace Ambition.Session {
	/**
	 * Store sessions in an Almanna-managed datastore.
	 */
	public class StorableAlmanna : Object,IStorable {
		private AlmannaSession entity = null;

		// This is construct because we dynamically load via Object.new.
		construct {
			init();
		}

		public void init() {
			string? entity_type = Config.lookup("session.entity_type");
			if ( entity_type == null ) {
				Logger.error("StorableAlmanna requires session.entity_type in config.");
				return;
			}

			if ( "." in entity_type ) {
				entity_type = entity_type.replace( ".", "" );
			}
			Type t = Type.from_name(entity_type);
			if ( t > 0 ) {
				entity = (AlmannaSession) Object.new(t);
			} else {
				Logger.error("StorableAlmanna requires a valid session.entity_type in config. Is the type registered?");
			}
		}

		public void store( string session_id, Interface i ) {
			var v = (AlmannaSession) entity.search().eq( "session_id", session_id ).single();
			if ( v == null ) {
				var t = entity.get_class().get_type();
				v = (AlmannaSession) Object.new(t);
				v.seal();
				v.session_id = session_id;
			}
			v.session_data = i.serialize();
			v.save();
			v = null;
		}

		public Interface? retrieve( string session_id ) {
			var v = (AlmannaSession) entity.search().eq( "session_id", session_id ).single();
			if ( v != null ) {
				return new Interface.from_serialized( session_id, v.session_data );
			}
			return null;
		}
	}
}