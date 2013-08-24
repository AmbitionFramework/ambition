/*
 * TBSelectGroupInput.vala
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
	 * <select />
	 */
	public class TBSelectGroupInput : TBGroupInput {
		public TBSelectGroupInput.with_options( string[] values, string[] labels ) {
			base.with_options( values, labels );
		}

		protected override string assemble_values( string form_name, string field, string? value ) {
			var sb = new StringBuilder();
			var hm = new HashMap<string,string>();
			hm.set( "name", field );
			hm.set( "id", make_id( form_name, field ) );

			for ( int option_index = 0; option_index < values.length; option_index++ ) {				
				var input_hm = new HashMap<string,string>();
				input_hm.set( "value", values[option_index] );
				if ( value != null && values[option_index] == value ) {
					input_hm.set( "selected", "selected" );
				}
				sb.append( option( input_hm, labels[option_index] ) );
			}
			return select( hm, sb.str );
		}
	}
}
