/*
 * Application.vala
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

namespace Skra {
	public class Application : Ambition.Application {

		public override Ambition.Actions get_actions() {
			return new Actions();
		}

		public override bool init( string[] args ) {
			return initialize_wiki();
		}

		/**
		 * If this has never been run, add a default wiki to the project.
		 */
		private bool initialize_wiki() {
			try {
				var destination_dir = File.new_for_path( Config.lookup_with_default( "wiki.directory", "wiki" ) );
				if ( destination_dir.query_exists() ) {
					return true;
				}

				destination_dir.make_directory();
				directory_enumerate( "default", destination_dir );
			} catch (Error e) {
				Logger.error( "Unable to initialize: %s".printf(e.message) );
				return false;
			}

			return true;
		}

		private void directory_enumerate( string directory_path, File destination_dir ) throws Error {
			File directory = File.new_for_path(directory_path);
			var enumerator = directory.enumerate_children(
				FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, 0
			);

			FileInfo file_info;
			while ( ( file_info = enumerator.next_file() ) != null ) {
				File dest = File.new_for_path( "%s/%s".printf( destination_dir.get_path(), file_info.get_name() ) );
				if ( file_info.get_file_type() != FileType.DIRECTORY ) {
					File to_copy = directory.resolve_relative_path( file_info.get_name() );
					to_copy.copy( dest, FileCopyFlags.NONE );
				} else {
					dest.make_directory();
					directory_enumerate( "%s/%s".printf( directory_path, file_info.get_name() ), dest );
				}
			}
		}
	}
}
