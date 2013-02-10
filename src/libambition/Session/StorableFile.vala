/*
 * StorableFile.vala
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

using Ambition;
using Gee;

namespace Ambition.Session {
	/**
	 * Implementation to store sessions on the filesystem. Not the fastest thing
	 * in the world, but probably the easiest. Stores sessions in the system
	 * temporary directory by default, or reads "storable.file.path" from the
	 * application config.
	 */
	public class StorableFile : Object,IStorable {

		public void store( string session_id, Interface i ) {
			string full_path = get_file_root() + "/" + session_id + ".session";
			FileStream session_file = FileStream.open( full_path, "w" );
			session_file.printf( i.serialize() );
		}

		public Interface? retrieve( string session_id ) {
			var file = File.new_for_path( get_file_root() + "/" + session_id + ".session" );
			if ( !file.query_exists() ) {
				Logger.info("Session not found");
				return null;
			}
			try {
				var sb = new StringBuilder();
				var dis = new DataInputStream( file.read() );
				string line;
				while ( ( line = dis.read_line(null) ) != null ) {
					sb.append(line);
				}
				return new Interface.from_serialized( session_id, sb.str );
			} catch (Error e) {
				Logger.warn( "Error reading from storage: %s".printf( e.message ) );
			}
			return null;
		}

		private string get_file_root() {
			return Config.lookup_with_default( "storable.file.path", GLib.Environment.get_tmp_dir() );
		}

	}
}