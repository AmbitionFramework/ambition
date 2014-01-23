/*
 * coreview_file.vala
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

public class CoreViewFileTest {
	public static void add_tests() {
		Test.add_func("/ambition/coreview/file/init/one", () => {
			var r = new Ambition.CoreView.File( get_file() );
			assert( r != null );
		});
		Test.add_func("/ambition/coreview/file/init/two", () => {
			var r = new Ambition.CoreView.File( get_file(), "text/plain" );
			assert( r != null );
		});
		Test.add_func("/ambition/coreview/file/validate", () => {
			var r = new Ambition.CoreView.File( get_file(), "text/plain" );
			r.state = new Ambition.State("a");
			r.state.request = new Ambition.Request();
			r.state.response = new Ambition.Response();

			var nis = r.render();
			assert( nis != null );
			assert( r.size > 0 );
			assert( r.state.response.content_type == "text/plain" );

			var s = new Ambition.CoreView.File( get_file(), "application/javascript" );
			s.state = r.state;

			nis = s.render();
			assert( nis != null );
			assert( s.size > 0 );
			assert( s.state.response.content_type == "application/javascript" );
		});
	}

	private static File get_file() {
		return File.new_for_path("assets/flat_file");
	}
}