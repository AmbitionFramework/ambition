/*
 * config.vala
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

public class ConfigTest {
	public static void add_tests() {
		Test.add_func("/ambition/configinstance/init", () => {
			var c = new Ambition.ConfigInstance();
			assert( c != null );
		});
		Test.add_func("/ambition/configinstance/lookup", () => {
			var c = new Ambition.ConfigInstance();
			assert( c != null );
			c.parse_config_file( get_test_file() );
			assert( c.config_hash != null );
			assert( c.lookup("app.name") == "Example" );
			assert( c.lookup("static.directories") == "static" );
			assert( c.lookup("nothing") == null );
		});
		Test.add_func("/ambition/configinstance/lookup_with_default", () => {
			var c = new Ambition.ConfigInstance();
			assert( c != null );
			c.parse_config_file( get_test_file() );
			assert( c.config_hash != null );
			assert( c.lookup_with_default("app.name", "null") == "Example" );
			assert( c.lookup_with_default("static.directories", "null") == "static" );
			assert( c.lookup_with_default("nothing", "something") != null );
			assert( c.lookup_with_default("nothing", "something") == "something" );
		});
		Test.add_func("/ambition/config/lookup", () => {
			var c = Ambition.Config.get_instance();
			assert( c != null );
			c.parse_config_file( get_test_file() );
			assert( c.config_hash != null );
			assert( Ambition.Config.lookup("app.name") == "Example" );
			assert( Ambition.Config.lookup("static.directories") == "static" );
			assert( Ambition.Config.lookup("nothing") == null );
		});
	}

	public static File get_test_file() {
		return File.new_for_path("assets/example.conf");
	}
}
