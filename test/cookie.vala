/*
 * cookie.vala
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

public class CookieTest {
	public static void add_tests() {
		Test.add_func("/ambition/cookie/init", () => {
			var c = new Ambition.Cookie();
			assert( c != null );
		});
		Test.add_func("/ambition/cookie/invalid", () => {
			var c = new Ambition.Cookie();
			assert( c.is_valid() == false );
		});
		Test.add_func("/ambition/cookie/valid", () => {
			var c = new Ambition.Cookie();
			c.name = "foo";
			c.value = "bar";
			c.max_age = 2;
			assert( c.is_valid() == true );
		});
		Test.add_func("/ambition/cookie/render", () => {
			var c = new Ambition.Cookie();
			c.name = "foo";
			c.value = "bar";
			c.max_age = 2;
			c.secure = true;
			assert( c.render() == "foo=bar; Path=/; Max-Age=2; Secure" );
		});
	}
}