/*
 * App.vala
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
using Ambition.Authorization;

namespace Ambition {
	public static const double VERSION_DOUBLE = 0.100;
	public static const string VERSION = "0.1";

	/**
	 * This needs to be somewhere else. to_array() combined with joinv is a
	 * recipe for segfaults, so this is a layer of protection until I figure
	 * out what might be wrong.
	 * @param separator String to separate strings
	 * @param list ArrayList of strings to join
	 */
	public string arraylist_joinv( string separator, ArrayList<string> list ) {
		if ( list == null || list.size == 0 ) {
			return "";
		}

		string[] list_array = new string[list.size];
		int f_index = 0;
		foreach ( string f in list ) {
			if ( f == null ) {
				f = "";
			}
			list_array[f_index++] = f;
		}
		return string.joinv( separator, list_array );
	}

	/**
	 * Static methods for keeping global application state.
	 */
	public class App : Object {
		/**
		 * Registered authorizers for the current application.
		 */
		public static HashMap<string,IAuthorizer> authorizers;

		/**
		 * Registered password types for the current application.
		 */
		public static HashMap<string,IPasswordType> password_types;

		/**
		 * Log level.
		 */
		public static int log_level;

		/**
		 * Set the current log level from a string.
		 */
		public static void set_log_level( string log_level ) {
			switch (log_level) {
				case "debug":
					App.log_level = 0;
					break;
				case "info":
					App.log_level = 1;
					break;
				case "warn":
					App.log_level = 2;
					break;
				case "error":
					App.log_level = 3;
					break;
			}
		}
	}
}