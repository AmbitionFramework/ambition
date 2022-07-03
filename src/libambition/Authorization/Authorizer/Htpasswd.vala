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
using Ambition.Authorization;
namespace Ambition.Authorization.Authorizer {
	/**
	 * Authorize users using a standard Apache htpasswd file.
	 */
	public class Htpasswd : Object,IAuthorizer {
		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.Authorization.Authorizer.Htpasswd");
		protected HashMap<string,string> config { get; set; }
		private HashMap<string,string> cache { get; set; default = new HashMap<string,string>(); }
		private string file_path { get; set; }

		private const string sixtyfour = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

		public void init( HashMap<string,string> config ) {
			this.config = config;

			this.file_path = config.get("file");
			string cache = config.get("cache");
			if ( cache != null && ( cache == "1" || cache == "true" ) ) {
				// not supported
			}
		}

		public IPasswordType? get_password_type_instance() {
			return null;
		}

		public IUser? authorize( string username, string password, HashMap<string,string>? options = null ) {
			var base_password = get_password_for_user(username);
			string crypted_pass = null;
			if ( base_password != null ) {
				if ( base_password.has_prefix("$apr1") ) {
					// MD5
					string[] split = base_password.split("$");
					string salt = split[2];
					crypted_pass = apr_md5_crypt( password, salt );
				}
				if ( crypted_pass == base_password ) {
					return new User.Htpasswd.with_params( get_line_number_for_user(username), username );
				}
			}
			return null;
		}

		public IUser? get_user_from_serialized( string serialized ) {
			var user = new User.Htpasswd();
			user.deserialize(serialized);
			if ( user.id > 0 ) {
				return user;
			}
			return null;
		}

		private string apr_md5_crypt( string to_crypt, string salt ) {
			var base_a = new Checksum( ChecksumType.MD5 );
			base_a.update( to_crypt.data, to_crypt.length );
			base_a.update( "$apr1$".data , 6);
			base_a.update( salt.data, salt.length );

			var final = new Checksum( ChecksumType.MD5 );
			final.update( to_crypt.data, to_crypt.length );
			final.update( salt.data, salt.length );
			final.update( to_crypt.data, to_crypt.length );
			uint8[] final_digest = new uint8[16];
			size_t digest_len = 16;
			final.get_digest( final_digest, ref digest_len );

			int pl, i, j;
			for ( pl = to_crypt.length; pl > 0; pl -= 16 ) {
				base_a.update( final_digest[0:( pl > 16 ? 16 : pl )], ( pl > 16 ? 16 : pl ) );
			}
			for ( i = to_crypt.length; i != 0; i >>= 1 ) {
				if ( (i & 1) != 0 ) {
					uchar c = 0;
					base_a.update( {(char)c}, 1 );
				} else {
					base_a.update( to_crypt.substring( 0, 1 ).data, 1 );
				}
			}
			base_a.get_digest( final_digest, ref digest_len );

			for ( j = 0; j < 1000; j++ ) {
				var base_b = new Checksum( ChecksumType.MD5 );
				if ( (j & 1) != 0 ) {
					base_b.update( to_crypt.data, to_crypt.length );
				} else {
					base_b.update( final_digest[0:16], 16 );
				}
				if ( (j % 3) != 0 ) {
					base_b.update( salt.data, salt.length );
				}
				if ( (j % 7) != 0 ) {
					base_b.update( to_crypt.data, to_crypt.length );
				}
				if ( (j & 1) != 0 ) {
					base_b.update( final_digest[0:16], 16  );
				} else {
					base_b.update( to_crypt.data, to_crypt.length );
				}
				base_b.get_digest( final_digest, ref digest_len );
			}

			var sb = new StringBuilder();
			sb.append( to64( (final_digest[0] << 16 | final_digest[6] << 8  | final_digest[12]), 4 ) );
			sb.append( to64( (final_digest[1] << 16 | final_digest[7] << 8  | final_digest[13]), 4 ) );
			sb.append( to64( (final_digest[2] << 16 | final_digest[8] << 8  | final_digest[14]), 4 ) );
			sb.append( to64( (final_digest[3] << 16 | final_digest[9] << 8  | final_digest[15]), 4 ) );
			sb.append( to64( (final_digest[4] << 16 | final_digest[10] << 8 | final_digest[5] ), 4 ) );
			sb.append( to64( final_digest[11], 2 ) );

			sb.prepend("$");
			sb.prepend(salt);
			sb.prepend("$apr1$");

			return sb.str;
		}

		private string to64( int v, int n ) {
			var sb = new StringBuilder();
			while ( --n >= 0 ) {
				sb.append( sixtyfour.substring( ( v & 0x3f ), 1 ) );
				v >>= 6;
			}
			return sb.str;
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
						string[] pair = line.split(":");
						if ( pair[0] == username ) {
							return pair[1];
						}
					}
				}
			} catch ( Error e ) {
				logger.error( "Error reading htpasswd file", e );
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
						string[] pair = line.split(":");
						if ( pair[0] == username ) {
							return line_number;
						}
					}
				}
			} catch ( Error e ) {
				logger.error( "Error reading htpasswd file", e );
			}
			return 0;
		}
	}
}
