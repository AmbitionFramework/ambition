/*
 * coreview_redirect.vala
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

public class CoreViewRedirectTest {
	public static void add_tests() {
		Test.add_func("/ambition/coreview/redirect/init", () => {
			var r = new Ambition.CoreView.Redirect("/");
			assert( r != null );
		});
		Test.add_func("/ambition/coreview/redirect/validate", () => {
			var r = new Ambition.CoreView.Redirect("/foo");
			r.state = new Ambition.State("a");
			r.state.request = new Ambition.Request();
			r.state.response = new Ambition.Response();

			assert( r.size == 0 );
			assert( r.render() == null );
			assert( r.state.response.status == 302 );
			assert( r.state.response.is_done() == true );
			assert( r.state.response.headers["Location"] == "/foo" );

			r = new Ambition.CoreView.Redirect( "/foo", 500 );
			r.state = new Ambition.State("a");
			r.state.request = new Ambition.Request();
			r.state.response = new Ambition.Response();

			assert( r.size == 0 );
			assert( r.render() == null );
			assert( r.state.response.status == 500 );
			assert( r.state.response.is_done() == true );
			assert( r.state.response.headers["Location"] == "/foo" );
		});
	}
}