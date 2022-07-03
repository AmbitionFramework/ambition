/*
 * Application.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *	 http://www.apache.org/licenses/LICENSE-2.0
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
		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Skra.Application");

		public override void create_routes() {
			add_route()
					.path("/")
					.method( HttpMethod.GET )
					.target( Controller.Root.index );
			add_route()
					.path("/session")
					.method( HttpMethod.GET )
					.target( Controller.Root.begin )
					.target( Controller.Root.session );
			add_route()
					.path("/auth/login")
					.method( HttpMethod.GET )
					.method( HttpMethod.POST )
					.target( Controller.Root.begin )
					.target( Controller.Auth.login );
			add_route()
					.path("/auth/logout")
					.method( HttpMethod.GET )
					.method( HttpMethod.POST )
					.target( Controller.Root.begin )
					.target( Controller.Auth.logout );
			add_route()
					.path("/wiki.*/history")
					.method( HttpMethod.GET )
					.target( Controller.Root.begin )
					.target( Controller.Wiki.begin )
					.target( Controller.Wiki.history );
			add_route()
					.path("/wiki.*/edit")
					.method( HttpMethod.GET )
					.method( HttpMethod.POST )
					.target( Controller.Root.begin )
					.target( Controller.Wiki.begin )
					.target( Controller.Wiki.edit );
			add_route()
					.path("/wiki.*/preview")
					.method( HttpMethod.GET )
					.method( HttpMethod.POST )
					.target( Controller.Root.begin )
					.target( Controller.Wiki.begin )
					.target( Controller.Wiki.preview );
			add_route()
					.path("/wiki/[node]")
					.method( HttpMethod.GET )
					.target( Controller.Root.begin )
					.target( Controller.Wiki.begin )
					.target( Controller.Wiki.index );
			add_route()
					.path("/wiki")
					.method( HttpMethod.GET )
					.target( Controller.Root.begin )
					.target( Controller.Wiki.begin )
					.target( Controller.Wiki.index );
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
				logger.error( "Unable to initialize: %s".printf(e.message) );
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
