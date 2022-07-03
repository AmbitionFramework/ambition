/*
 * controller_static.vala
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

public class ControllerStaticTest {
	public static void add_tests() {
		Test.add_func("/ambition/controller/static/init", () => {
			Ambition.Config.set_value( "static.directories", "static" );

			var al = Ambition.Controller.Static.add_routes();
			assert( al != null );
			assert( al.size == 2 );
		});
		Test.add_func("/ambition/controller/static/render", () => {
			Ambition.Config.set_value( "static.directories", "static" );

			Ambition.Controller.Static.add_routes();

			var state = new Ambition.State("1");
			var request = new Ambition.Request();

			request.path = "/static/formsubclass.vala";
			state.request = request;
			state.response = new Ambition.Response();
		});
	}
}
