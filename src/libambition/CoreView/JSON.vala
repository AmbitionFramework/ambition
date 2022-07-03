/*
 * JSON.vala
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

namespace Ambition.CoreView {
	/**
	 * Renders a JsonNode or serializes a GObject as Json.
	 */
	public class JSON : Result {
		public override State state { get; set; }
		public override int64 size { get; set; }
		public string? content_type { get; set; }
		private Json.Node node { get; set; }
		private bool pretty { get; set; }

		/**
		 * Create a Json view, serializing the provided GObject instance.
		 * 
		 * A target GObject must either contain simple properties, or implement
		 * the Serializable interface to describe to json-glib how to convert
		 * that object. Since it will use glib property names, note that the "_"
		 * character will be replaced with "-".
		 * 
		 * @param object GObject to serialize.
		 * @param pretty Default false. When true, outputs in formatted,
		 *               indented JSON.
		 */
		public JSON.with_object( Object object, bool convert_underlines = false, bool pretty = false ) throws Error {
			this.node = Json.gobject_serialize(object);
			this.pretty = pretty;
		}

		/**
		 * Create a Json view, using the provided Json.Node.
		 * @param node Json.Node instance.
		 * @param pretty Default false. When true, outputs in formatted,
		 *               indented JSON.
		 */
		public JSON.with_node( Json.Node node, bool convert_underlines = false, bool pretty = false ) {
			this.node = node;
			this.pretty = pretty;
		}

		public override InputStream? render() {
			size_t size = 0;
			var generator = new Json.Generator();
			generator.root = this.node;
			generator.pretty = this.pretty;
			string json_data = generator.to_data( out size );

			this.size = (int64) size;
			state.response.content_type = "application/json";
			return new MemoryInputStream.from_data( json_data.data, GLib.g_free );
		}
	}
}
