/*
 * FormDefinition.vala
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
	 * Representation of a HTML form, providing form validation, auto-fill,
	 * and rendering.
	 */
	public abstract class FormDefinition : Object {
		public Request request { get; set; }
		public string form_name { get; set; default = ""; }
		public ArrayList<string> form_errors = new ArrayList<string>();
		public HashMap<string,ArrayList<string>> field_errors = new HashMap<string,ArrayList<string>>();

		/**
		 * Bind the form with a valid State object
		 * @param state State object
		 */
		public void bind_state( State state ) {
			this.bind_request( state.request );
		}

		/**
		 * Bind the form with a valid Request object
		 * @param request Request object
		 */
		public void bind_request( Request request ) {
			this.request = request;
			do_property_bind();
		}

		/**
		 * Run validation on the given form. Returns true if validation passed,
		 * false if it did not. Check errors for results of errors.
		 * @return boolean
		 */
		public bool is_valid() {
			return ( validate_form() && !has_errors() );
		}

		/**
		 * Returns true if any form or field errors have occurred during
		 * validation.
		 * @return boolean
		 */
		public bool has_errors() {
			if ( this.form_errors.size > 0 || this.field_errors.size > 0 ) {
				return true;
			}
			return false;
		}

		/**
		 * Add an error that is not specific to a field.
		 * @param error_string Error text
		 */
		public void add_form_error( string error_string ) {
			this.form_errors.add(error_string);
		}

		/**
		 * Add an error that is specific to a field.
		 * @param field        Name of the field/property 
		 * @param error_string Error text
		 */
		public void add_field_error( string field, string error_string ) {
			if ( !this.field_errors.has_key(field) ) {
				this.field_errors.set( field, new ArrayList<string>() );
			}
			this.field_errors.get(field).add(error_string);
		}

		/**
		 * Retrieve all form errors
		 * @return ArrayList<string> of errors
		 */
		public ArrayList<string> get_form_errors() {
			return this.form_errors;
		}

		/**
		 * Retrieve errors for a given field
		 * @param field Field/property name
		 * @return ArrayList<string> of errors
		 */
		public ArrayList<string> get_field_errors( string field ) {
			if ( this.field_errors.has_key(field) ) {
				return this.field_errors.get(field);
			}
			return new ArrayList<string>();
		}

		/**
		 * Render a given field/property with the given field renderer
		 * @param field    Field/property name
		 * @param renderer A Ambition.Form.FieldRenderer object
		 * @return string containing the rendered content
		 */
		public string render_field( string field, FieldRenderer renderer ) {
			string gfield = field.replace( "_", "-" );
			ParamSpec p = this.get_class().find_property(gfield);
			if ( p != null ) {
				string converted_value = "";
				Value v = Value( p.value_type );
				this.get_property( field, ref v );
				switch ( p.value_type.name() ) {
					case "gchararray":  // string
						converted_value = v.get_string();
						break;
					case "gint": // int
						converted_value = v.get_int().to_string();
						break;
					case "gdouble": // double
						converted_value = v.get_double().to_string();
						break;
					case "gchar": // char
						converted_value = v.get_char().to_string();
						break;
					case "gboolean": // bool
						converted_value = v.get_boolean().to_string();
						break;
					case "GStrv": // string[]
						string[] arrayed = (string[]) v.get_boxed();
						if ( arrayed != null ) {
							converted_value = string.joinv( ",", arrayed );
						}
						break;
				}

				return renderer.render( this.form_name, field, converted_value, p.get_nick(), p.get_blurb(), get_field_errors(field).to_array() );
			}
			Logger.error( "Field not found: %s".printf(field) );
			return "";
		}

		/**
		 * Perform custom form validation.
		 *
		 * This method returns true by default, and is designed to be
		 * overridden by the subclass for any custom form-wide validation.
		 * The success of this method is not dependent on field-level
		 * validation.
		 *
		 * @return boolean on the success of validation /from this method/
		 */
		public virtual bool validate_form() {
			return true;
		}

		/*
		 * Haaaaaaaaacks
		 */
		protected void do_property_bind() {
			ParamSpec[] properties = this.get_class().list_properties();
			foreach ( ParamSpec p in properties ) {
				string param_name = p.name.replace( "-", "_" );
				if ( param_name != "request" && this.request.params.has_key( param_name ) ) {
					string param_value = this.request.param( param_name );
					Value v = Value( p.value_type );
					bool has_value = true;
					switch ( p.value_type.name() ) {
						case "gchararray":  // string
							v.set_string(param_value);
							break;
						case "gint": // int
							v.set_int( int.parse(param_value) );
							break;
						case "gdouble": // double
							v.set_double( double.parse(param_value) );
							break;
						case "gchar": // char
							v.set_char( param_value[0] );
							break;
						case "gboolean": // bool
							// Forms can be funny, let's make assumptions
							if ( param_value == "1" || param_value == "on" ) {
								param_value = "true";
							} else if ( param_value == "0" || param_value == "off" ) {
								param_value = "false";
							}
							v.set_boolean( bool.parse(param_value) );
							break;
						case "GStrv": // string[]
							string[] arrayed = param_value.split(",");
							v.set_boxed(arrayed);
							break;
						default:
							has_value = false;
							break;
					}
					if (has_value) {
						this.set_property( p.name, v );
					}
				}
			}
		}

	}
}
