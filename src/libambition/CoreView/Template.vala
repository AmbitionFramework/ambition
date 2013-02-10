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
	 * Returns a template.
	 */
	public abstract class Template : Result {
		public override InputStream? render() {
			string result = to_string();
			size = result.length;
			return new MemoryInputStream.from_data( result.data, GLib.g_free );
		}

		/**
		 * Render a template into a string.
		 */
		public abstract string to_string();

		/**
		 * Render a template into a string, providing the current state. This
		 * should only be used when attempting to render outside of the normal
		 * dispatch cycle.
		 * @param state Valid State object.
		 */
		public string to_string_with_state( State state ) {
			this.state = state;
			return to_string();
		}
	}
}
