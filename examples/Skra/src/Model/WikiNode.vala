/*
 * WikiNode.vala
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
namespace Skra.Model {
	/**
	 * Model to work with a node in the wiki.
	 */
	public class WikiNode : Object {
		/**
		 * Given a path, attempt to find this node on the filesystem
		 * @param path Node path
		 */
		public static string? retrieve_latest( string path ) {
			string root_path = Environment.get_current_dir() + "/wiki";
			string search_path = root_path + "/" + path + "/index";
			return get_file_contents(search_path);
		}

		/**
		 * Given a path and a version, attempt to find this node on the
		 * filesystem
		 * @param path    Node path
		 * @param version Version number
		 */
		public static string? retrieve_version( string path, int version ) {
			string root_path = Environment.get_current_dir() + "/wiki";
			string search_path = root_path + "/" + path + "/" + version.to_string();
			return get_file_contents(search_path);
		}

		/**
		 * Given a path, retrieve HashMap<string,long> with a version number and
		 * the unix timestamp of modification. Returns null if the node does not
		 * exist.
		 * @param path Node path
		 */
		public static HashMap<string,long>? version_list( string path ) {
			string root_path = Environment.get_current_dir() + "/wiki";
			string search_path = root_path + "/" + path + "/";
			if ( exists( search_path + "index" ) == null ) {
				return null;
			}

			FileInfo file_info;
			var hm = new HashMap<string,long>();
			var directory = File.new_for_path(search_path);
			var enumerator = directory.enumerate_children(
				string.joinv( ",", { FileAttribute.STANDARD_NAME, FileAttribute.TIME_MODIFIED, FileAttribute.STANDARD_TYPE } ),
				0
			);
			while ( ( file_info = enumerator.next_file() ) != null ) {
				if ( file_info.get_name() != "index" && file_info.get_file_type() != FileType.DIRECTORY ) {
#if VALA_0_16
					TimeVal v = file_info.get_modification_time();
#else
					TimeVal v;
					file_info.get_modification_time( out v );
#endif
					hm.set( file_info.get_name(), v.tv_sec );
				}
			}
			return hm;
		}

		/**
		 * Given a path and content, save a node
		 * @param path    Node path
		 * @param content Content of the page
		 * @return bool
		 */
		public static bool save( string path, string content ) {
			string root_path = Environment.get_current_dir() + "/wiki";
			string search_path = root_path + "/" + path + "/index";
			int latest = 0;
			if ( exists(search_path) == null ) {
				// Create directory
				try {
					var dir = File.new_for_path( root_path + "/" + path );
					dir.make_directory();
				} catch ( Error e ) {
					Logger.error( e.message );
					return false;
				}
			} else {
				// Find latest number
				FileInfo file_info;
				var directory = File.new_for_path( root_path + "/" + path );
				var enumerator = directory.enumerate_children( FileAttribute.STANDARD_NAME, 0 );
				while ( ( file_info = enumerator.next_file() ) != null ) {
					if ( file_info.get_name() != "index" ) {
						int num = int.parse( file_info.get_name() );
						if ( num > latest ) {
							latest = num;
						}
					}
				}
			}
			// Create version
			latest++;
			var file = File.new_for_path( root_path + "/" + path + "/" + latest.to_string() );
			try {
				var file_stream = file.create( FileCreateFlags.NONE );
				if ( !file.query_exists() ) {
					Logger.error( "Cannot create '%s'".printf(path) );
				}
				var data_stream = new DataOutputStream(file_stream);
				data_stream.put_string(content);
			} catch ( Error e ) {
				Logger.error( e.message );
				return false;
			}
			// Copy to index
			var index = File.new_for_path(search_path);
			try {
	        	file.copy( index, FileCopyFlags.OVERWRITE );
	        } catch ( Error e ) {
				Logger.error( e.message );
				file.delete();
				return false;
	        }
        	return true;
		}

		/**
		 * Determine if a file exists.
		 * @param path Path to file/directory
		 */
		private static File? exists( string path ) {
		    var file = File.new_for_path(path);
			if ( !file.query_exists() ) {
				return null;
			}

			return file;
		}

		/**
		 * Slurp the file at the given path into a string.
		 * @param search_path Path to file.
		 */
		private static string? get_file_contents( string search_path ) {
			var file = exists(search_path);
			if ( file != null ) {
				var sb = new StringBuilder();
				try {
					string line;
					var is = new DataInputStream( file.read() );
					while ( ( line = is.read_line(null) ) != null ) {
						sb.append( line + "\n" );
					}
				} catch (Error e) {
					return null;
				}
				return sb.str;
			}
			return null;
		} 
	}
}
