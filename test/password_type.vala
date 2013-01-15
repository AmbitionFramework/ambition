/*
 * password_type.vala
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

public class PasswordTypeTest {
	public static void add_tests() {
		Test.add_func("/ambition/authorizer/password_type/sha1", () => {
			var a = new Ambition.Authorization.PasswordType.SHA1();
			assert( a != null );
			a.init( new Gee.HashMap<string,string>() );

			string example_password = "foobar123";

			// No config, no options
			assert( a.convert(example_password) == "6ffd8b80f2a76ca670ae33ab196f7936d59fb43b" );

			// No config, option iterations
			var hm = new Gee.HashMap<string,string>();
			hm["iterations"] = "2";
			assert( a.convert( example_password, hm ) == "e33224ac3834b368883f4486d31f02423369aec0" );

			// No config, option pre_salt
			hm = new Gee.HashMap<string,string>();
			hm["pre_salt"] = "whee!";
			assert( a.convert( example_password, hm ) == "c4e35d2ea1cf6e9c2c029bee5158f31bc5a4c844" );

			// No config, option pre_salt + post_salt
			hm["post_salt"] = "!woo";
			assert( a.convert( example_password, hm ) == "ab87ce0130388439a0f5e816a0c2fbe627ec010d" );

			// No config, option post_salt
			hm = new Gee.HashMap<string,string>();
			hm["post_salt"] = "!woo";
			assert( a.convert( example_password, hm ) == "fcefbb25a4c5508c13af8394948096f4b7769e03" );

			// Config pre_salt, no options
			hm = new Gee.HashMap<string,string>();
			hm["pre_salt"] = "whee!";
			a.init(hm);
			assert( a.convert(example_password) == "c4e35d2ea1cf6e9c2c029bee5158f31bc5a4c844" );

			// Config pre_salt, option pre_salt
			var hm_options = new Gee.HashMap<string,string>();
			hm_options["pre_salt"] = "whoa";
			assert( a.convert( example_password, hm_options ) == "f90d0d58ee094b293bbff8538d4c6d84be739cb5" );
		});

		Test.add_func("/ambition/authorizer/password_type/md5", () => {
			var a = new Ambition.Authorization.PasswordType.MD5();
			assert( a != null );
			a.init( new Gee.HashMap<string,string>() );

			string example_password = "foobar123";

			// No config, no options
			assert( a.convert(example_password) == "ae2d699aca20886f6bed96a0425c6168" );

			// No config, option pre_salt
			var hm = new Gee.HashMap<string,string>();
			hm["pre_salt"] = "whee!";
			assert( a.convert( example_password, hm ) == "5c94559fb258f5633718e61311f9d5ed" );
		});
	}
}