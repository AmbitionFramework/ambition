/*
 * request.vala
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

public class RequestTest {
	public static void add_tests() {
		Test.add_func("/ambition/request/init", () => {
			var r = new Ambition.Request();
			assert( r != null );
		});
		Test.add_func("/ambition/request/params_from_string", () => {

			// Simple character
			var param_map = Ambition.Request.params_from_string("_=1291727469299");
			assert( param_map != null );
			assert( param_map.size == 1 );
			assert( param_map["_"] == "1291727469299" );

			// Keyword without equal sign
			param_map = Ambition.Request.params_from_string(
				"randomparameterstring"
			);
			assert( param_map != null );
			assert( param_map.size == 1 );
			assert( param_map["randomparameterstring"] == "" );

			// Semi-colon support
			param_map = Ambition.Request.params_from_string(
				"a=foo;b=bar;a=baz"
			);
			assert( param_map != null );
			assert( param_map.size == 2 );
			assert( param_map["a"] == "foo,baz" );
			assert( param_map["b"] == "bar" );

			// From http://unixpapa.com/js/querystring.html
			param_map = Ambition.Request.params_from_string(
				"key1=&key2&search=Rock+%26+Roll&rock%26roll=here+to+stay&key3=dog&key3=cat&key3=mouse&weird=%26%CE%A8%E2%88%88"
			);
			assert( param_map != null );
			assert( param_map.size == 6 );
			assert( param_map["key1"] == "" );
			assert( param_map["key2"] == "" );
			assert( param_map["key3"] == "dog,cat,mouse" );
			assert( param_map["rock&roll"] == "here to stay" );
			assert( param_map["search"] == "Rock & Roll" );
			assert( param_map["weird"] != null );
		});
		Test.add_func("/ambition/request/set_uri", () => {
			var r = new Ambition.Request();
			assert( r != null );

			r.set_uri( "http", "www.google.com", "/test/url", "/test/url" );
			assert( r.uri == "http://www.google.com/test/url" );
			assert( r.host == "www.google.com" );
			assert( r.port == 80 );

			r.set_uri( "https", "www.google.com:443", "/test/url", "/test/url" );
			assert( r.uri == "https://www.google.com:443/test/url" );
			assert( r.host == "www.google.com:443" );
			assert( r.port == 443 );
		});
		Test.add_func("/ambition/request/initialize", () => {
			var r = new Ambition.Request();
			assert( r != null );

			r.initialize(
				Ambition.HttpMethod.GET,
				"127.0.0.1",
				"http",
				"www.google.com",
				"/test/url",
				"/test/url",
				new Gee.HashMap<string,string>(),
				new Gee.HashMap<string,string>()
			);
			assert( r.uri == "http://www.google.com/test/url" );
			assert( r.host == "www.google.com" );
			assert( r.port == 80 );
			assert( r.ip == "127.0.0.1" );
			assert( r.method == Ambition.HttpMethod.GET );
		});
	}
}