/*
 * Button.vala
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
	/**
	 * <button type="button" />
	 */
	public class Button : FieldRenderer {
		protected string input_type { get; set; default = "button"; }

		public override string render( string form_name, string field, string? value = "", string? nick = null, string? blurb = null, string[]? errors = null ) {
			string id = make_id( form_name, field );
			var input_hm = new HashMap<string,string>();
			input_hm.set( "type", input_type );
			input_hm.set( "id", id );
			input_hm.set( "name", field );
			return button( input_hm, nick );
		}
	}
}
