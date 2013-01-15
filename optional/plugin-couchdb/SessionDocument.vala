/*
 * SessionDocument.vala
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

using Ambition.Couch;
namespace Ambition.Session {
	public class SessionDocument : Document {
		public override string database_name { get; set; default = Config.lookup_with_default( "couch.session.database", "session" ); }
		public string session_data { get; set; default = ""; }

		public SessionDocument() {}

		public SessionDocument.from_document( Couchdb.Document document ) {
			load(document);
		}

		public SessionDocument.from_id( string id ) {
			try {
				load_from_id(id);
			} catch (Error e) {
				Logger.error( "Cannot load document %s: %s".printf( id, e.message ) );
			}
		}

		public override string generate_id() {
			return "";
		}
	}
}