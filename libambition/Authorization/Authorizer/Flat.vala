/*
 * Flat.vala
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
using Ambition.Authorization;
namespace Ambition.Authorization.Authorizer {
	/**
	 * Authorize users using a flat file.
	 */
	public class Flat : Object,IAuthorizer {
		protected HashMap<string,string> config { get; set; }
		private string file_path { get; set; }
		private string delimiter { get; set; default = "|"; }
		private string password_type { get; set; default = "SHA1"; }

		public void init( HashMap<string,string> config ) {
			this.config = config;

			this.file_path = config.get("file");
			string delimiter = config.get("delimiter");
			if ( delimiter != null ) {
				this.delimiter = delimiter;
			}
			string password_type = config.get("password_type");
			if ( password_type != null ) {
				this.password_type = password_type;
			}
		}

		public IUser? authorize( string username, string password, HashMap<string,string>? options = null ) {
			var p_type = get_password_type_from_string(password_type);
			var base_password = get_password_for_user(username);
			if ( base_password != null ) {
				if ( p_type.convert( password, options ) == base_password ) {
					return new User.Flat.with_params( get_line_number_for_user(username), username );
				}
			}
			return null;
		}

		public IUser? get_user_from_serialized( string serialized ) {
			var user = new User.Flat();
			user.deserialize(serialized);
			if ( user.id > 0 ) {
				return user;
			}
			return null;
		}

		private string? get_password_for_user( string username ) {
			var file = File.new_for_path(file_path);
			if ( !file.query_exists() ) {
				return null;
			}

			try {
				var input_stream = new DataInputStream( file.read() );
				string line;
				while ( ( line = input_stream.read_line(null) ) != null ) {
					if ( ! line.has_prefix("#") ) {
						string[] pair = line.split(delimiter);
						if ( pair[0] == username ) {
							return pair[1];
						}
					}
				}
			} catch ( Error e ) {
				Logger.error( e.message );
			}
			return null;
		}

		private int get_line_number_for_user( string username ) {
			var file = File.new_for_path(file_path);
			if ( !file.query_exists() ) {
				return 0;
			}

			try {
				var input_stream = new DataInputStream( file.read() );
				string line;
				int line_number = 0;
				while ( ( line = input_stream.read_line(null) ) != null ) {
					line_number++;
					if ( ! line.has_prefix("#") ) {
						string[] pair = line.split(delimiter);
						if ( pair[0] == username ) {
							return line_number;
						}
					}
				}
			} catch ( Error e ) {
				Logger.error( e.message );
			}
			return 0;
		}
	}
}
