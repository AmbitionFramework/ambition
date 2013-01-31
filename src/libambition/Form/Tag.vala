/*
 * Tag.vala
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

using Gee;
namespace Ambition.Form {
	public interface Tag : Object {
		public string a ( HashMap<string,string>? params, string? content = null ) {
			return generic( "input", params, content );
		}

		public string input ( HashMap<string,string>? params, string? content = null ) {
			return generic( "input", params, content );
		}

		public string button ( HashMap<string,string>? params, string? content = null ) {
			return generic( "button", params, content );
		}

		public string textarea ( HashMap<string,string>? params, string? content = null ) {
			return generic( "textarea", params, content );
		}

		public string div ( HashMap<string,string>? params, string? content = null ) {
			return generic( "div", params, content );
		}

		public string span ( HashMap<string,string>? params, string? content = null ) {
			return generic( "span", params, content );
		}

		public string dd ( HashMap<string,string>? params, string? content = null ) {
			return generic( "dd", params, content );
		}

		public string dt ( HashMap<string,string>? params, string? content = null ) {
			return generic( "dt", params, content );
		}

		public string dl ( HashMap<string,string>? params, string? content = null ) {
			return generic( "dl", params, content );
		}

		public string select ( HashMap<string,string>? params, string? content = null ) {
			return generic( "select", params, content );
		}

		public string option ( HashMap<string,string>? params, string? content = null ) {
			return generic( "option", params, content );
		}

		/**
		 * <label for="x" />
		 * @param field_for ID of the input this label is for
		 * @param content   Content for the inside of the label
		 * @return string
		 */
		public string label ( string field_for, string? content = null ) {
			var hm = new HashMap<string,string>();
			hm.set( "for", field_for );
			return generic( "label", hm, content );
		}

		/**
		 * <label class="y" for="x" />
		 * @param class_name Class name
		 * @param field_for  ID of the input this label is for
		 * @param content    Content for the inside of the label
		 * @return string
		 */
		public string label_class ( string class_name, string field_for, string? content = null ) {
			var hm = new HashMap<string,string>();
			hm.set( "class", class_name );
			hm.set( "for", field_for );
			return generic( "label", hm, content );
		}

		public string generic ( string tag_name, HashMap<string,string>? params, string? content = null ) {
			var sb = new StringBuilder();
			sb.append("<");
			sb.append(tag_name);
			if ( params != null ) {
				foreach ( string k in params.keys ) {
					sb.append(" ");
					sb.append(k);
					sb.append("=\"");
					if ( params.get(k) != null ) {
						sb.append( params.get(k).replace( "\"", "\\\"" ) );
					}
					sb.append("\"");
				}
			}
			if ( content != null ) {
				sb.append(">");
				sb.append(content);
				sb.append("</");
				sb.append(tag_name);
				sb.append(">");
			} else {
				sb.append(" />");
			}
			return sb.str;
		}
	}
}
