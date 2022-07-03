/*
 * RequestFile.vala
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

using Gee;
namespace Ambition {
	public class RequestFile : Object {
		/**
		 * File name, as reported by the request.
		 */
		public string filename { get; set; }

		/**
		 * Content type, as reported by the request.
		 */
		public string content_type { get; set; }

		/**
		 * File object pointing to the local temporary file with the contents
		 * of this file.
		 */
		public File file { get; set; }

		/**
		 * Default constructor.
		 */
		public RequestFile() {}

		/**
		 * Construct RequestFile with contents of the object.
		 * @param filename File name
		 * @param content_type Content type
		 * @param file Valid File object
		 */
		public RequestFile.with_contents( string filename, string content_type, File file ) {
			this.filename = filename;
			this.content_type = content_type;
			this.file = file;
		}
	}
}
