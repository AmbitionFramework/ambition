/*
 * app.vala
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

public class AppTest : Ambition.Testing.AbstractTestCase {
	public AppTest() {
		base("Ambition.App");
		add_test( "init", init );
		add_test( "VERSION", version );
		add_test( "parse_version", parse_version );
	}

	public void init() {
		var a = new Ambition.App();
		assert( a != null );
	}

	public void version() {
		assert( Ambition.VERSION != null );
	}

	public void parse_version() {
		int ver = Ambition.parse_version("0.1");
		assert( ver == 1000100 );
		ver = Ambition.parse_version("0.1.1");
		assert( ver == 1000101 );
		ver = Ambition.parse_version("2.0.1");
		assert( ver == 1020001 );
	}
}
