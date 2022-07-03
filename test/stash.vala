/*
 * stash.vala
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

public class StashTest {
	public static void add_tests() {
		Test.add_func("/ambition/stash/init", () => {
			var s = new Ambition.Stash();
			assert( s != null );
		});
		Test.add_func("/ambition/stash/value/setget", () => {
			var s = new Ambition.Stash();
			assert( s != null );
			Value v = Value( typeof(string) );
			v.set_string("foo");
			s.set( "test", v );
			assert( s.size == 1 );
			var v2 = s.get("test");
			assert( v2 != null );
			assert( v2.get_string() == "foo" );
		});
		Test.add_func("/ambition/stash/value/setgetvala", () => {
			var s = new Ambition.Stash();
			assert( s != null );
			Value v = Value( typeof(string) );
			v.set_string("foo");
			s["test"] = v;
			assert( s.size == 1 );
			var v2 = s["test"];
			assert( v2 != null );
			assert( v2.get_string() == "foo" );
		});
		Test.add_func("/ambition/stash/object/setget", () => {
			var s = new Ambition.Stash();
			assert( s != null );
			var hm = new Gee.HashMap<string,string>();
			hm["test"] = "foo";
			s.set_object( "test", hm );
			assert( s.size == 1 );
			var v2 = s.get_object("test");
			assert( v2 != null );
			var vhm = (Gee.HashMap<string,string>) v2;
			assert( vhm != null );
			assert( vhm["test"] == "foo" );
		});
		Test.add_func("/ambition/stash/string/setget", () => {
			var s = new Ambition.Stash();
			assert( s != null );
			var str = "foo";
			s.set_string( "test", str );
			assert( s.size == 1 );
			var v2 = s.get_string("test");
			assert( v2 != null );
			assert( v2 == "foo" );
		});
		Test.add_func("/ambition/stash/boolean/setget", () => {
			var s = new Ambition.Stash();
			assert( s != null );
			var boolean = true;
			s.set_boolean( "test", boolean );
			assert( s.size == 1 );
			var v2 = s.get_boolean("test");
			assert( v2 == true );
		});
		Test.add_func("/ambition/stash/float/setget", () => {
			var s = new Ambition.Stash();
			assert( s != null );
			var fl = 1234.56f;
			s.set_float( "test", fl );
			assert( s.size == 1 );
			var v2 = s.get_float("test");
			assert( v2 == 1234.56f );
		});
		Test.add_func("/ambition/stash/int64/setget", () => {
			var s = new Ambition.Stash();
			assert( s != null );
			var i6 = 1234567890;
			s.set_int64( "test", i6 );
			assert( s.size == 1 );
			var v2 = s.get_int64("test");
			assert( v2 == 1234567890 );
		});
		Test.add_func("/ambition/stash/int/setget", () => {
			var s = new Ambition.Stash();
			assert( s != null );
			var i = 123456;
			s.set_int( "test", i );
			assert( s.size == 1 );
			var v2 = s.get_int("test");
			assert( v2 == 123456 );
		});
		Test.add_func("/ambition/stash/double/setget", () => {
			var s = new Ambition.Stash();
			assert( s != null );
			var d = 123456.78;
			s.set_double( "test", d );
			assert( s.size == 1 );
			var v2 = s.get_double("test");
			assert( v2 == 123456.78 );
		});
	}
}
