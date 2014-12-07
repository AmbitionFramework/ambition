/*
 * app.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2014 Sensical, Inc.
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

public class AppTest {
	public static void add_tests() {
		Test.add_func("/ambition/app/init", () => {
			var a = new Ambition.App();
			assert( a != null );
		});
		Test.add_func("/ambition/app/VERSION", () => {
			assert( Ambition.VERSION != null );
		});
		Test.add_func("/ambition/app/parse_version", () => {
			int ver = Ambition.parse_version("0.1");
			assert( ver == 1000100 );
			ver = Ambition.parse_version("0.1.1");
			assert( ver == 1000101 );
			ver = Ambition.parse_version("2.0.1");
			assert( ver == 1020001 );
		});
	}
}