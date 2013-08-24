/*
 * TBTextarea.vala
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
	 * <textarea />
	 */
	public class TBTextarea : FieldRenderer {
		public string? class_attribute { get; set; }

		public TBTextarea.with_class( string class_attribute ) {
			this.class_attribute = class_attribute;
		}

		public override string render( string form_name, string field, string? value = "", string? nick, string? blurb, string[]? errors = null ) {
			string id = make_id( form_name, field );

			var div_hm = new HashMap<string,string>();
			div_hm["class"] = "control-group";

			var div_control_hm = new HashMap<string,string>();
			div_control_hm["class"] = "controls";

			var textarea_hm = new HashMap<string,string>();
			textarea_hm.set( "id", id );
			textarea_hm.set( "name", field );
			if ( this.class_attribute != null ) {
				textarea_hm.set( "class", class_attribute );
			}
			string span_text = "";
			if ( blurb != null && blurb != field ) {
				span_text = blurb;
			}
			if ( errors != null ) {
				div_hm["class"] = div_hm["class"] + " error";
				foreach ( string error in errors ) {
					span_text = error;
				}
			}
			if ( span_text.length > 0 ) {
				var span_hm = new HashMap<string,string>();
				span_hm.set( "class", "help-block" );
				span_hm.set( "id", id + "_hint" );
				span_text = span( span_hm, span_text );
			}
			return div(
				div_hm,
				( nick != null && nick != field ? label_class( "control-label", id, nick ) : "" )
				+ div(
					div_control_hm,
					textarea( textarea_hm, ( value != null ? value : "" ) )
					+ span_text
				)
			);
		}
	}
}
