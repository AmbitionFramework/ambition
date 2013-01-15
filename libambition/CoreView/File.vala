/*
 * File.vala
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
	 * Returns a file.
	 */
	public class File : Result {
		public override State state { get; set; }
		public override int64 size { get; set; }
		private GLib.File file { get; set; }
		private string? content_type { get; set; }

		/**
		 * Create a File view, to the file provided. A content type may be
		 * provided, but will attempt to detect if one is not provided.
		 * @param file File object.
		 * @param content_type Optional MIME content type.
		 */
		public File( GLib.File file, string? content_type = null ) {
			this.file = file;
			this.content_type = content_type;
		}

		public override InputStream? render() {
			try {
				var file_info = file.query_info( "*", FileQueryInfoFlags.NONE );
				state.response.content_type = ( content_type != null ? content_type : file_info.get_content_type() );
				size = file_info.get_size();
				return file.read();
			} catch ( Error e ) {
				Logger.error( e.message );
				state.response.status = 500;
				state.response.body = "";
				return null;
			}
		}
	}
}
