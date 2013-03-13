/*
 * Utility.vala
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
	 * Get current application name.
	 */
	public static string? get_application_name() {
		var project_dir = File.new_for_path(".");
		if (
			!project_dir.query_exists()
			|| project_dir.query_file_type(FileQueryInfoFlags.NONE) != FileType.DIRECTORY
		) {
			Logger.error("Somehow, we are not in a project directory.");
			return null;
		}
		return project_dir.get_basename();
	}

	/**
	 * Soft wrap a string at a given column.
	 * @param text Text to display and wrap
	 * @param indent Default = 4, level of indentation for string
	 */
	public static string? wrap_string( string text, int indent = 4 ) {
		int wrap_at = 80;
		var sb = new StringBuilder();
		foreach ( string word in text.split(" ") ) {
			if ( sb.len >= wrap_at || sb.len + word.length > wrap_at ) {
				stdout.printf( "%s\n", sb.str );
				sb = new StringBuilder();
			}
			if ( sb.len > 0 ) {
				sb.append(" ");
			} else {
				for ( int i = 0; i < indent; i++ ) {
					sb.append(" ");
				}
			}
			sb.append(word);
		}
		return sb.str;
	}

	/**
	 * Soft wrap a string at a given column.
	 * @param text Text to display and wrap
	 * @param indent Default = 4, level of indentation for string
	 */
	public static void wrap( string text, int indent = 4 ) {
		stdout.printf( "%s\n", wrap_string( text, indent ) );
	}
}
