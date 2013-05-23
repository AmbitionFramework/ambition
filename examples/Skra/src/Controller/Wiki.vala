/*
 * Wiki.vala
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
using Skra.View;
using Skra.Model;
namespace Skra.Controller {
	public class Wiki : Object {

		public Result begin( State state ) {
			string node_path = state.request.path.substring(1);
			string[] nodes = node_path.split("/");
			if ( nodes[0] == "wiki" ) {
				if ( nodes.length > 1 ) {
					nodes = nodes[1:nodes.length];
				} else {
					nodes = {};
				}
			}

			if ( nodes.length > 0 ) {
				string last = nodes[ nodes.length - 1 ];
				if ( last == "edit" || last == "preview" || last == "history" ) {
					nodes = nodes[0:nodes.length - 1];
				}
			}

			node_path = string.joinv( "/", nodes );
			string path = get_path(node_path);
			if ( path == null ) {
				return show_404( state, node_path );
			}

			state.stash.set_string( "node_path", node_path );
			state.stash.set_string( "path", path );
			return new CoreView.None();
		}

		public Result history( State state ) {
			string path = state.stash.get_string("path");
			return new Template.Wiki.history(
				state.stash.get_string("node_path"),
				WikiNode.version_list(path)
			);
		}

		public Result edit( State state ) {
			if ( !check_authorization(state) ) {
				return new CoreView.None();
			}
			string path = state.stash.get_string("path");
			if ( state.request.method == HttpMethod.POST ) {
				var result = WikiNode.save( path, state.request.param("edit") );
				if ( result == true ) {
					return new CoreView.Redirect( "/wiki/" + path );
				}
			}
			string content = WikiNode.retrieve_latest(path);
			string parsed;
			if ( content == null ) {
				content = "";
				parsed = "";
			} else {
				parsed = WikiMarkdown.process(content);
			}
			return new Template.Wiki.edit(
				state.stash.get_string("node_path"),
				content,
				parsed
			);
		}

		public Result preview( State state ) {
			return new Template.Wiki.preview(
				WikiMarkdown.process( state.stash.get_string("edit") )
			);
		}

		public Result index( State state ) {
			string node_path = state.stash.get_string("node_path");
			string path = state.stash.get_string("path");

			string content = null;
			if ( state.request.param("version") != null ) {
				content = WikiNode.retrieve_version( path, int.parse( state.request.param("version") ) );
			} else {
				content = WikiNode.retrieve_latest(path);
			}
			if ( content == null ) {
				return show_404( state, node_path );
			}
			return new Template.Wiki.node(
				WikiMarkdown.process(content),
				node_path,
				true
			);
		}

		public Result show_404( State state, string node_path ) {
			state.response.status = 404;
			state.response.done();
			return new Template.Wiki.node(
				"",
				node_path,
				false
			);
		}

		public string? get_path( string args ) {
			string path = "";

			if ( args != null && args.length > 0 ) {
				// Check if we're trying to traverse
				foreach ( string arg in args.split("/") ) {
					if ( ".." in arg ) {
						return null;
					}
					path = path + ( path.length > 0 ? "/" : "" ) + arg;
				}
			}

			return path;
		}

		public bool check_authorization( State state ) {
			if ( !state.has_user ) {
				state.response.redirect( "/wiki/" + state.stash.get_string("node_path") );
				return false;
			}
			return true;
		}

	}
}
