/*
 * form.vala
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

public class FormTest {
	public static Ambition.Request get_request() {
		var r = new Ambition.Request();
		r.params = new Gee.HashMap<string,string>();
		return r;
	}
	public static void add_tests() {
		Test.add_func("/ambition/form/init", () => {
			var f = new FormSubclass();
			assert( f != null );
		});
		Test.add_func("/ambition/form/bind", () => {
			var r = get_request();

			var f = new FormSubclass();
			f.bind_request(r);
			assert( f != null );
		});
		Test.add_func("/ambition/form/string", () => {
			var r = get_request();
			r.params.set( "first_name", "Foo" );
			assert( r.param("first_name") == "Foo" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert( f != null );
			assert( f.first_name == "Foo" );
		});
		Test.add_func("/ambition/form/multistring", () => {
			var r = get_request();
			r.params.set( "multiselect", "foo,bar" );
			assert( r.param("multiselect") == "foo,bar" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert( f != null );
			assert( f.multiselect[0] == "foo" );
			assert( f.multiselect[1] == "bar" );
		});
		Test.add_func("/ambition/form/integer", () => {
			var r = get_request();
			r.params.set( "age", "81" );
			assert( r.param("age") == "81" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert( f != null );
			assert( f.age == 81 );
		});
		Test.add_func("/ambition/form/bool/1", () => {
			var r = get_request();
			r.params.set( "has_registered", "1" );
			assert( r.param("has_registered") == "1" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert( f != null );
			assert( f.has_registered == true );
		});
		Test.add_func("/ambition/form/bool/0", () => {
			var r = get_request();
			r.params.set( "has_registered", "0" );
			assert( r.param("has_registered") == "0" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert( f != null );
			assert( f.has_registered == false );
		});
		Test.add_func("/ambition/form/bool/true", () => {
			var r = get_request();
			r.params.set( "has_registered", "true" );
			assert( r.param("has_registered") == "true" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert( f != null );
			assert( f.has_registered == true );
		});
		Test.add_func("/ambition/form/bool/false", () => {
			var r = get_request();
			r.params.set( "has_registered", "false" );
			assert( r.param("has_registered") == "false" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert( f != null );
			assert( f.has_registered == false );
		});
		Test.add_func("/ambition/form/bool/on", () => {
			var r = get_request();
			r.params.set( "has_registered", "on" );
			assert( r.param("has_registered") == "on" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert( f != null );
			assert( f.has_registered == true );
		});
		Test.add_func("/ambition/form/bool/off", () => {
			var r = get_request();
			r.params.set( "has_registered", "off" );
			assert( r.param("has_registered") == "off" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert( f != null );
			assert( f.has_registered == false );
		});
		Test.add_func("/ambition/form/char", () => {
			var r = get_request();
			r.params.set( "gender", "F" );
			assert( r.param("gender") == "F" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert( f != null );
			assert( f.gender == 'F' );
		});
		Test.add_func("/ambition/form/double", () => {
			var r = get_request();
			r.params.set( "balance", "15.21" );
			assert( r.param("balance") == "15.21" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert( f != null );
			assert( f.balance == 15.21 );
		});
		Test.add_func("/ambition/form/unsupported", () => {
			var r = get_request();
			r.params.set( "unsupported", "2" );
			assert( r.param("unsupported") == "2" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert( f != null );
			assert( f.unsupported == 0 );
		});
	}
}
