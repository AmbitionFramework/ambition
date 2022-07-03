/*
 * Result.vala
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
	 * Represents the result of a controller method.
	 */
	public abstract class Result : Object {
		/**
		 * The State of the current request.
		 */
		public abstract State state { get; set; }

		/**
		 * The size of the input stream.
		 */
		public abstract int64 size { get; set; }

		/**
		 * Render the current view as an InputStream.
		 */
		public abstract InputStream? render();
	}
}
