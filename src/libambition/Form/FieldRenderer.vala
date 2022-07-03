/*
 * FieldRenderer.vala
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
namespace Ambition.Form {
	/**
	 * Base class for a field renderer. Implements render() method.
	 */
	public abstract class FieldRenderer : Object,Tag {
		/**
		 * Renders the given field/property to HTML or just about anything else.
		 * @param form_name Form name
		 * @param field     Field/property name
		 * @param value     Value of that field/property
		 * @param nick      GObject "nick" of the property
		 * @param blurb     GObject "blurb" of the property
		 * @return string containing the content
		 */
		public abstract string render( string form_name, string field, string? value = "", string? nick = null, string? blurb = null, string[]? errors = null );

		public string make_id( string form_name, string field ) {
			return form_name + "_" + field;
		}
	}
}
