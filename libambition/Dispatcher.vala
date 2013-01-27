/*
 * Dispatcher.vala
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
using Ambition.PluginSupport;

namespace Ambition {
	/**
	 * Core entry point of an Ambition application, providing methods to
	 * dispatch a request from a web endpoint to a method or series of methods.
	 */
	public class Dispatcher : Object {
		private Engine.Base _engine = null;
		private bool show_powered_by = false;
		private string[] args;

		public Engine.Base engine {
			get {
				 return _engine;
			}
			set {
				_engine = value;
				_engine.dispatcher = this;
			}
		}

		public ArrayList<Action?> actions { get; set; }
		public ArrayList<IPlugin?> plugins { get; private set; default = new ArrayList<IPlugin?>(); }

		public Dispatcher( string[] args ) {
			// Register dynamic types
			typeof(Engine.Raw).name();

			set_default_config(args);

			App.set_log_level( Config.lookup_with_default( "app.log_level", "debug" ) );

			this.args = args;
		}

		public static void set_default_config( string[] args ) {
			// Get executable path
			string executable_path = args[0];
			if ( executable_path.substring( 0, 1 ) != "/" ) {
				executable_path = Environment.get_current_dir() + "/" + executable_path;
			}
			if ( executable_path.has_suffix("-bin") ) {
				executable_path = executable_path.substring( 0, executable_path.length - 4 );
			}
			int last_index = executable_path.last_index_of_char('/');
			Config.set_value( "ambition.app_name", executable_path.substring( last_index + 1 ) );
			Config.set_value( "ambition.app_path", executable_path.substring( 0, last_index ) );
		}
		
		public bool run() {
			if ( actions == null ) {
				Logger.error("No actions specified, nothing to do!");
				return false;
			}

			// Load plugins
			this.plugins = PluginLoader.load_plugins_from_directory("plugins");
			this.plugins.add( new Session.SessionPlugin() );

			execute_startup_hooks();

			// Parse engine config, if available
			if ( Config.lookup("engine") != null ) {
				load_engine_from_string( Config.lookup("app.engine") );
			}

			// Parse command line options
			int arg_index = 0;
			foreach ( string element in args ) {
				if ( element == "--engine" ) {
					// Attempt to load engine
					string engine_name = args[arg_index + 1];
					load_engine_from_string(engine_name);
					break;
				}
				arg_index++;
			}

			// Get a default engine
			if ( engine == null ) {
				engine = new Engine.Raw();
			}

			// Show actions
			this.actions.add_all( Controller.Static.add_actions() );
			Logger.debug("Actions:");
			foreach ( var action in actions ) {
				Regex re = action._regex;
				if ( action.methods.size == 0 ) {
					action.methods.add( HttpMethod.ALL );
				}

				if ( App.log_level == Logger.DEBUG ) {
					var methods = new ArrayList<string>();
					foreach ( HttpMethod hm in action.methods ) {
						methods.add( hm.to_string().substring( 0, 1 ) );
					}

					var targets = new ArrayList<string>();
					foreach ( ActionMethod am in action.targets ) {
						targets.add( am.path );
					}

					Logger.debug(
						" %-4s %-32s %s".printf(
							arraylist_joinv( "", methods ),
							( re.get_pattern().length > 32 ? ( re.get_pattern().substring( 0, 31 ) + "…" ) : re.get_pattern() ),
							arraylist_joinv( " > ", targets )
						)
					);
				}
			}

			// Create authorizers
			Authorization.Builder.build_authorizers();
			if ( App.authorizers.size > 0 ) {
				Logger.debug("Authorizers:");
				foreach ( var authorizer_name in App.authorizers.keys ) {
					Logger.debug(
						" %s (%s)".printf(
							authorizer_name,
							App.authorizers[authorizer_name]
								.get_type()
								.name()
								.replace( "AmbitionAuthorization", "" )
								.replace( "Authorizer", "" )
						)
					);
				}
			}

			// Cache runtime config
			this.show_powered_by = ( Config.lookup("app.show_powered_by") == "1" ? true : false );

			this.engine.execute();
			return true;
		}
		
		/** 
		 * Initialize our State with new Response and Request objects,
		 * etc. To be called immediately upon request acceptance by an
		 * Engine.
		 * @param id Identifier for this State.
		 */
		public State initialize_state( string id ) {
			var state = new State(id);
			state.dispatcher = this;
			state.request = new Request();
			state.response = new Response();

			return state;
		}

		/**
		 * AFTER a State has been initialized by an engine with 
		 * request headers, cookies and a session prepared, THEN
		 * run a request through the dispatcher. Iterate through each path to
		 * determine if the request matches, run through those actions, and
		 * set up the response.
		 * @param state Current engine state
		 */
		public void handle_request( State state ) {
			state.log.info("");
			state.log.info( "Request from %s: %s %s".printf(
				state.request.ip,
				state.request.method.to_string(),
				state.request.path
			) );

			// Call on_request_dispatch hook on registered plugins.
			foreach( IPlugin p in this.plugins ) {
				p.on_request_dispatch(state);
			}

			ArrayList<ActionMethod?> action_list = null;
			string decoded_path = Uri.unescape_string( state.request.path );
			foreach ( var action in actions ) {
				Regex re = action._regex;
				MatchInfo info = null;
				if ( re.match( decoded_path, 0, out info ) ) {
					state.log.debug( "Matched pattern %s".printf( re.get_pattern() ) );
					state.request.captures = info.fetch_all();

					// Determine named captures
					var re_named = /\(?<([\w\d_]+)>/;
					MatchInfo named_info = null;
					if ( re_named.match( re.get_pattern(), 0, out named_info ) ) {
						var matches = named_info.fetch_all();
						foreach ( string match in matches ) {
							state.request.named_captures[match] = info.fetch_named(match);
						}
					}

					// Determine arguments
					if ( !action._regex.get_pattern().has_suffix("$/") ) {
						try {
							state.request._arguments = re.replace( decoded_path, -1, 0, "" );
						} catch ( RegexError e ) {
							Logger.error("Invalid regex for arguments");
						}
					}

					action_list = action.targets;
					break;
				}
			}

			if ( action_list != null && action_list.size > 0 ) {
				var action_response = execute_action_list( action_list, state );
				display_action_response( action_response, state );
			}

			// Call on_request_end hook on registered plugins.
			foreach( IPlugin p in this.plugins ) {
				p.on_request_end(state);
			}

			// Set powered by if required
			if (show_powered_by) {
				state.response.set_header( "X-Powered-By", "Ambition" );
			}

			// Output response
			state.log.info( "Rendered %lld bytes, type %s, status %d".printf(
				state.response.get_body_length(),
				state.response.content_type,
				state.response.status
			) );
			state.log.info( "Dispatch & render: %0.4f ms".printf( state.elapsed_ms() ) );
		}

		/**
		 * Add actions from an Actions subclass.
		 * @param actions Actions subclass
		 */
		public void add_actions_class( Actions actions ) {
			var action_array = actions.actions();
			if ( action_array.length > 0 ) {
				if ( this.actions == null ) {
					this.actions = new ArrayList<Action?>();
				}
				foreach( var action in action_array ) {
					this.actions.add(action);
				}
			}
		}

		/**
		 * Output the calculated action list
		 * @param action_result Calculated action list
		 */
		public void display_action_response( ArrayList<string> action_result, State state ) {
			foreach ( string a in action_result ) {
				state.log.debug(a);
			}
		}

		/**
		 * Execute the calculated action list
		 * @param action_list List of ActionMethods
		 * @param state State object
		 */
		public ArrayList<string> execute_action_list( ArrayList<ActionMethod?> action_list, State state ) {
			var al = new ArrayList<string>();
			foreach ( ActionMethod a in action_list ) {
				Result? r = a.execute(state);
				if ( r != null && ! (r is CoreView.None) ) {
					r.state = state;
					InputStream? eis = r.render();
					if ( eis != null ) {
						state.response.body_stream = eis;
						state.response.body_stream_length = r.size;
					}
				}
				al.add( "|> %s".printf( a.path != null ? a.path : "/generic/action" ) );
				if ( state.response.is_done() ) {
					break;
				}
			}
			return al;
		}

		private void execute_startup_hooks() {
			// Initialize Plugins
			foreach ( IPlugin p in plugins ) {
				p.register_plugin();
				Logger.info( "Registered plugin '%s'.".printf( p.name ) );
				p.on_application_start(this);
			}
		}

		private void load_engine_from_string( string engine_name ) {
			Type t = Type.from_name( "AmbitionEngine%s".printf(engine_name) );
			if ( t > 0 ) {
				this.engine = (Engine.Base) Object.new(t);
			} else {
				Logger.error( "Invalid engine specified: %s".printf(engine_name) );
			}
		}
	}
}
