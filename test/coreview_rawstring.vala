/*
 * coreview_json.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
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

public class CoreViewRawStringTest {
	public static void add_tests() {
		Test.add_func("/ambition/coreview/rawstring/init", () => {
			var r = new Ambition.CoreView.RawString("Test String");
			assert( r != null );
		});
		Test.add_func("/ambition/coreview/rawstring/validate", () => {
			var r = new Ambition.CoreView.RawString("Test String");
			r.state = new Ambition.State("a");
			r.state.request = new Ambition.Request();
			r.state.response = new Ambition.Response();

			var nis = r.render();
			assert( nis != null );
			assert( r.size == 11 );
			assert( r.state.response.content_type == "text/html" );

			uint8 buffer[512];
			size_t read = 1;
			while ( read > 0 ) {
				read = nis.read(buffer);
			}

			assert( (string) buffer == "Test String" );
		});
	}
}
