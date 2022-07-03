/*
 * coreview_none.vala
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

public class CoreViewNoneTest {
	public static void add_tests() {
		Test.add_func("/ambition/coreview/none/init", () => {
			var r = new Ambition.CoreView.None();
			assert( r != null );
		});
		Test.add_func("/ambition/coreview/none/validate", () => {
			var r = new Ambition.CoreView.None();
			assert( r != null );
			assert( r.size == 0 );
			assert( r.render() == null );
		});
	}
}
