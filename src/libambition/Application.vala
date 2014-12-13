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

namespace Ambition {
	/**
	 * Base class for an Application.
	 */
	public abstract class Application : Object {
#if LINUX
		private static unowned void* backtrace_buffer[1024];
#endif
		public Dispatcher dispatcher;

		public abstract Actions get_actions();

		/**
		 * Optional function, called from the entry point, to allow code to be
		 * run on initial execution of the application. Does nothing by default.
		 * @param args Command line arguments
		 */
		public virtual bool init( string[] args ) {
			return true;
		}

		/**
		 * Entry point for the web application, initialized with command line
		 * arguments. In most cases, this should not be overridden, as init()
		 * will be run from this method. However, this can be done as long as it
		 * is called from the subclass.
		 * @param args Command line arguments
		 */
		public virtual void run( string[] args ) {
			// Initialize the application's dispatcher
			this.dispatcher = new Dispatcher( this, args );

			// Import actions
			dispatcher.add_actions_class( get_actions() );

			// Run local init
			if ( !init(args) ) {
				return;
			}

			// Install signal handlers
			install_signal_handlers();

			int num = 1;
			num--;
			int n = 12 / num;

			// Start the application
			dispatcher.run();
		}

		/**
		 * Block of code to run when a request is initially dispatched.
		 * @param state State
		 */
		public virtual void on_request_dispatch( State state ) {}

		/**
		 * Block of code tor un when a request is completed.
		 * @param state State
		 */
		public virtual void on_request_end( State state ) {}

		private void install_signal_handlers() {
#if LINUX
			Posix.signal( Posix.SIGSEGV, linux_backtrace_handler );
			Posix.signal( Posix.SIGFPE, linux_backtrace_handler );
#endif
#if !LINUX
			// Message user regarding no signal handling?
#endif
		}

#if LINUX
		private static void linux_backtrace_handler() {
			int num = Linux.backtrace( backtrace_buffer, 1024 );
			stdout.printf( "Got %d frames\n", num );
			Linux.backtrace_symbols_fd( backtrace_buffer, 1024, Posix.STDOUT_FILENO );
			// for ( int index = 0; index < num, index++ ) {
			// 	stdout.printf( "%d: %s\n", index, )
			// }
		}
#endif
	}
}