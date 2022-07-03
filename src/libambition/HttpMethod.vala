/*
 * HttpMethod.vala
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

namespace Ambition {
	/**
	 * Represents an HTTP method.
	 */
	public enum HttpMethod {
		NONE,
		CONNECT,
		DELETE,
		GET,
		HEAD,
		OPTIONS,
		POST,
		PUT,
		TRACE,
		ALL;

		/**
		 * Return an HttpMethod by name.
		 */
		public static HttpMethod from_string( string method ) {
			EnumClass ec = (EnumClass) typeof(HttpMethod).class_ref();
			unowned EnumValue? ev = ec.get_value_by_nick( method.down() );
			if ( ev == null ) {
				return HttpMethod.NONE;
			}
			return (HttpMethod) ev.value;
		}

		/**
		 * Return this HttpMethod string
		 */
		public string to_string() {
			EnumClass ec = (EnumClass) typeof(HttpMethod).class_ref();
			unowned EnumValue? ev = ec.get_value(this);
			return ev.value_nick.up();
		}
	}
}
