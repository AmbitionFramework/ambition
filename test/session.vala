/*
 * session.vala
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

public class SessionTest {
	public static void add_tests() {
		Test.add_func("/ambition/session/interface/init", () => {
			var s = new Ambition.Session.Interface();
			assert( s != null );
			assert( s.session_id != null );
		});
		Test.add_func("/ambition/session/interface/initid", () => {
			var s = new Ambition.Session.Interface("0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33");
			assert( s != null );
			assert( s.session_id == "0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33" );
		});
		Test.add_func("/ambition/session/interface/setget", () => {
			var s = new Ambition.Session.Interface();
			s.set_value( "foo", "bar" );
			string g = s.get_value("foo");
			assert( g == "bar" );
		});
		Test.add_func("/ambition/session/interface/serialize", () => {
			var s = new Ambition.Session.Interface();
			s.set_value( "foo", "bar" );
			string ser = s.serialize();
			assert( ser == "YXMxxo18xo3GhnwvZm9vxoZ8xpViYXI=");
		});
		Test.add_func("/ambition/session/interface/deserialize", () => {
			var s = new Ambition.Session.Interface.from_serialized(
				"0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33",
				"YXMxxo18xo3GhnwvZm9vxoZ8xpViYXI="
			);
			string g = s.get_value("foo");
			assert( g == "bar" );
		});
		Test.add_func("/ambition/session/interface/has_data", () => {
			var s = new Ambition.Session.Interface();
			assert( s.has_data == false );
			s.set_value( "foo", "bar" );
			assert( s.has_data == true );
		});
	}
}