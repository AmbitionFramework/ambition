/*
 * dispatcher.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2016 Sensical, Inc.
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

public class DispatcherTest {
	public static void add_tests() {
		Test.add_func("/ambition/dispatcher/inject_to_application", () => {
			string[] args = { "test-ambition" };
			var a = new InjectTestApplication();
			var d = new Ambition.Dispatcher( a, args );
			assert( d != null );
			d.inject_to_application( typeof(string), "test" );
			assert( a.inject_string == "test" );
			assert( a.inject_string_default == "foo" );
			d.inject_to_application( typeof(Object), a );
			assert( a.inject_obj == a );
		});
	}
}


public class InjectTestApplication : Ambition.Application {
	public string inject_string { get; set; }
	public string inject_string_default { get; set; default = "foo"; }
	public Object inject_obj { get; set; }
	public override void create_routes() {}
}