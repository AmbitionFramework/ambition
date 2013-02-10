/*
 * Shell.vala
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

namespace Ambition.Utility {
	/**
	 * Provide an interactive shell to all of the commands provided by the 
	 * command line tool.
	 */
	public class Shell : Object {
		public int run() {
			stdout.printf( "Ambition %s Interactive Shell\n", Ambition.VERSION );
			stdout.printf( "Enter 'help' for help, 'exit' or ctrl-c to exit.\n\n" );

			while ( 1 == 1 ) {
				string response = Readline.readline( "(Ambition: %s) ".printf( get_application_name() ) );

				if ( response == "exit" ) {
					break;
				}
				string[] responses = response.split(" ");
				string[] empty = {};
				Utility.execute_command( true, responses[0], ( responses.length > 1 ? responses[1:response.length] : empty ) );

				Readline.History.add(response);
			}
			return 0;
		}
	}
}