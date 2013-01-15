/*
 * Static.vala
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
using Ambition;
namespace Ambition.Controller {
	/**
	 * Generic controller to handle static files from a supplied "static"
	 * directory.
	 */
	public class Static : Object {

		/**
		 * Add actions based on static directories defined in the configuration.
		 * @return ArrayList<Ambition.Action?> of the completed action list.
		 */
		public static ArrayList<Ambition.Action?> add_actions() {
			var actions = new ArrayList<Ambition.Action?>();
			string[] directories = Config.lookup_with_default( "static.directories", "" ).split(",");
			var s = new Static();

			// Add favicon.ico
			actions.add(
				new Action()
					.regex( /^\/favicon.ico$/ )
					.allow_method( HttpMethod.GET )
					.add_target_method( new ActionMethod( s.show_static_file, "/static" ) )
			);

			// Add any directories in config
			foreach ( string directory in directories ) {
				Regex re;
				try {
					re = new Regex( "^/" + directory.replace( "/", "\\/" ) );
				} catch (Error e) {
					continue;
				}
				actions.add(
					new Action()
						.regex(re)
						.allow_method( HttpMethod.GET )
						.add_target( s.show_static_file )
				);
			}
			return actions;
		}

		/**
		 * Action to display a static file based on the incoming path. This
		 * works by having an action defined to end up here, because this method
		 * doesn't care about the configuration.
		 * @param state State object
		 */
		public Result show_static_file( State state ) {
			string path = state.request.path;
			Response response = state.response;
			if ( path.length > 7 && path.substring( 0, 7 ) == "/static" ) {
				path = path.substring(7);
			}
			var file = File.new_for_path( Config.lookup_with_default( "static.root", "static" ) + path );
			if ( !file.query_exists() ) {
				response.status = 404;
				response.body = "";
				return new CoreView.None();
			}
			return new CoreView.File(file);
		}
	}

}
