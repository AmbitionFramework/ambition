/*
 * pluginmanifest.vala
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

public class PluginManifestTest {
	public static void add_tests() {
		Test.add_func("/ambition/pluginmanifest/init", () => {
			var s = new Ambition.Plugin.PluginManifest();
			assert( s != null );
		});
		Test.add_func("/ambition/pluginmanifest/check_version", () => {
			var s = new Ambition.Plugin.PluginManifest();
			assert( s != null );
			s.minimum_target_version = "0.1";
			s.maximum_target_version = "1.0";
			assert( s.check_version("0.1") == true );
			assert( s.check_version("0.1.1") == true );
			assert( s.check_version("1.0") == true );
			assert( s.check_version("2.0") == false );
		});
	}
}
