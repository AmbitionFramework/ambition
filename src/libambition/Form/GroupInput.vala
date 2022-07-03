/*
 * GroupInput.vala
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
	public abstract class GroupInput : FieldRenderer {
		protected string[] values;
		protected string[] labels;
		protected string input_type { get; set; }

		protected GroupInput.with_options( string[] values, string[] labels ) {
			this.values = values;
			this.labels = labels;
		}

		public override string render( string form_name, string field, string? value = "", string? nick = null, string? blurb = null, string[]? errors = null ) {
			string id = make_id( form_name, field );
			var main_sb = new StringBuilder();
			var input_sb = new StringBuilder();

			// Label
			main_sb.append( dt( null, label( id, ( nick == null ? field : nick ) ) ) );

			input_sb.append( assemble_values( form_name, field, value ) );

			string div_text = "";
			if ( blurb != null && blurb != field ) {
				var div_hm = new HashMap<string,string>();
				div_hm.set( "class", "input_hint" );
				div_hm.set( "id", id + "_hint" );
				div_text = div( div_hm, blurb );
			}
			if ( errors != null ) {
				var error_hm = new HashMap<string,string>();
				error_hm.set( "class", "input_hint_error" );
				foreach ( string error in errors ) {
					div_text = div_text + div( error_hm, error );
				}
			}
			input_sb.append(div_text);

			main_sb.append( dd( null, input_sb.str ) );
			return dl( null, main_sb.str );
		}

		protected virtual string assemble_values( string form_name, string field, string? value ) {
			var sb = new StringBuilder();
			for ( int option_index = 0; option_index < values.length; option_index++ ) {				
				var input_hm = new HashMap<string,string>();
				input_hm.set( "type", input_type );
				input_hm.set( "name", field );
				input_hm.set( "value", values[option_index] );
				sb.append( input(input_hm) );
				sb.append( span( null, labels[option_index] ) );
			}
			return sb.str;
		}
	}
}
