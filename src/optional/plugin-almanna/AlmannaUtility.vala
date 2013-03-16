/*
 * AlmannaUtility.vala
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

using Almanna;

public static Type init_utility() {
	return typeof(Ambition.Utility.AlmannaUtility);
}

namespace Ambition.Utility {
	/*
	 * Provide built-in support for the Almanna ORM, with entity registration
	 * and configuration via the application config file.
	 */
	public class AlmannaUtility : Object,IUtility {
		public string name { get { return "Almanna"; } }

		public void register_utility() {}

		public int receive_command( string[] args ) {
			string command = args[0];
			switch (command) {
				case "scaffold":
					string[] spawn_args = { "/usr/bin/almanna-generate" };
					foreach ( var arg in args ) {
						spawn_args += arg;
					}
					try {
						int exit_status;
						Process.spawn_sync(
							null,
							spawn_args,
							null,
							SpawnFlags.CHILD_INHERITS_STDIN,
							null,
							null,
							null,
							out exit_status
						);
					} catch (SpawnError wse) {
						Logger.error( "Unable to run scaffold: %s".printf( wse.message ) );
						return -1;
					}
					break;
				default:
					stdout.printf( "Invalid command.\n%s\n", help() );
					return -1;
			}
			return 0;
		}

		public string help() {
			return "almanna scaffold <options>\n"
			       + wrap_string( "Runs the Almanna scaffolder." );
		}
	}
}