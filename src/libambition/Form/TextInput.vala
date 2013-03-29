/*
 * TextInput.vala
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
	 * <input type="text" />
	 */
	public class TextInput : FieldRenderer {
		protected string input_type { get; set; default = "text"; }

		public override string render( string form_name, string field, string? value = "", string? nick, string? blurb, string[]? errors = null ) {
			string id = make_id( form_name, field );
			var input_hm = new HashMap<string,string>();
			input_hm.set( "type", input_type );
			input_hm.set( "id", id );
			input_hm.set( "name", field );
			input_hm.set( "value", value );
			string div_text = "";
			if ( blurb != null && blurb != field && blurb != field.replace( "_", "-" ) ) {
				var div_hm = new HashMap<string,string>();
				div_hm.set( "class", "input_hint" );
				div_hm.set( "id", id + "_hint" );
				div_text = div( div_hm, blurb );
			}
			if ( errors != null ) {
				input_hm.set( "class", "input_error" );

				var error_hm = new HashMap<string,string>();
				error_hm.set( "class", "input_hint_error" );
				foreach ( string error in errors ) {
					div_text = div_text + div( error_hm, error );
				}
			}
			return dl(
				null,
				dt(
					null,
					label( id, ( nick == null ? field : nick ) )
				)
				+ dd(
					null,
					input(input_hm) + div_text
				)
			);
		}
	}
}
