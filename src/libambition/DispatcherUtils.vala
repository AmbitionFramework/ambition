/*
 * DispatcherUtils.vala
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
	public class DispatcherUtils : Object {
		public static string find_controller_for_path( string path ) {
			return path.substring( 0, path.last_index_of("/") );
		}

		public static string? controller_to_path( string controller, string? method = null ) {
			var sb = new StringBuilder();
			try {
				Regex re_convert = new Regex("([a-z])([A-Z])");
				string filtered = controller.substring( controller.index_of(".Controller.") + 12 );
				filtered = re_convert.replace( filtered, -1, 0, "\\1_\\2" ).down();
				sb.append("/");
				sb.append( filtered.replace( ".", "/" ) );
				if ( method != null ) {
					sb.append("/");
					sb.append(method);
				}
			} catch ( RegexError re ) {
				stderr.printf( re.message );
				return null;
			}
			return sb.str;
		}
	}
}