/*
 * Template.vala
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

using Ambition;

namespace Ambition.CoreView {
	/**
	 * Returns a string. The default content type is text/html.
	 */
	public class RawString : Result {
		public override State state { get; set; }
		public override int64 size { get; set; }

		private string renderable { get; set; }
		private int code { get; set; default = 200; }

		/**
		 * Create a RawString view, with the provided string. A status code may
		 * be provided, but defaults to a 200.
		 * @param str String to return to the browser.
		 * @param code Optional status code to provide to the browser.
		 */
		public RawString( string str, int code = 200 ) {
			this.renderable = str;
			this.code = code;
		}

		public override InputStream? render() {
			size = renderable.length;
			if ( state.response.content_type == null ) {
				state.response.content_type = "text/html";
			}
			return new MemoryInputStream.from_data( renderable.data, GLib.g_free );
		}
	}
}
