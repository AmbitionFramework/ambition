/*
 * SCGIUtility.vala
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

public static Type init_utility() {
	return typeof( Ambition.Utility.SCGIUtility );
}

namespace Ambition.Utility {
	/*
	 * Add SCGI support to the ambition binary.
	 */
	public class SCGIUtility : Object,IUtility {
		public string name { get { return "SCGI"; } }

		public void register_utility() {}

		public int receive_command( string[] args ) {
			string command = args[0];
			switch (command) {
				case "configure":
					alter_config( "engine", "SCGI" );
					if ( args.length > 1 ) {
						alter_config( "scgi.port", args[1] );
					}
					break;
				default:
					stdout.printf( "Invalid command.\n%s\n", help() );
					return -1;
			}
			return 0;
		}

		public string help() {
			return "scgi configure <port>\n"
			       + wrap_string(
						"Configure the SCGI plugin for this application. "
						+ "Optionally takes a port number to add to the "
						+ "configuration."
					 );
		}
	}
}