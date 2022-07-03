/*
 * httpmethod.vala
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

using Ambition;

public class HttpMethodTest {
	public static void add_tests() {
		Test.add_func("/ambition/httpmethod", () => {
			HttpMethod m_get = HttpMethod.GET;
			HttpMethod d_get = HttpMethod.from_string("GET");
			assert( m_get == d_get );
			assert( HttpMethod.POST == HttpMethod.from_string("POST") );
			assert( HttpMethod.NONE == HttpMethod.from_string("FooO!") );
		});
	}
}
