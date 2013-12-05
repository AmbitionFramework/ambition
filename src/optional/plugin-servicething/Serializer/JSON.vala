/*
 * JSON.vala
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
namespace Ambition.PluginSupport.ServiceThing.Serializer {

	/**
	 * Serialize Service data to JSON.
	 */
	public class JSON : Object,ISerializer {
		public delegate void SerializeValue( Value v, Json.Builder b );
		public static HashMap<Type,SerializeValueWrapper> serializers { get; set; default = new HashMap<Type,SerializeValueWrapper>(); }

		public JSON() {
			serializers[ typeof(string) ] = new SerializeValueWrapper(serialize_string);
			serializers[ typeof(int) ] = new SerializeValueWrapper(serialize_int);
			serializers[ typeof(int16) ] = serializers[ typeof(int) ];
			serializers[ typeof(int32) ] = serializers[ typeof(int) ];
			serializers[ typeof(double) ] = new SerializeValueWrapper(serialize_double);
			serializers[ typeof(bool) ] = new SerializeValueWrapper(serialize_bool);
			serializers[ typeof(string[]) ] = new SerializeValueWrapper(serialize_stringarray);
			serializers[ typeof(ArrayList) ] = new SerializeValueWrapper(serialize_arraylist);
			serializers[ typeof(Object) ] = new SerializeValueWrapper(serialize_object);
		}

		public string? serialize( Object o ) {
			Json.Builder builder = new Json.Builder();

			serialize_object_as_object( o, builder );

			var generator = new Json.Generator();
			var root = builder.get_root();
			generator.set_root(root);
			if ( JSONConfig.pretty_print ) {
				generator.pretty = true;
			}
			return generator.to_data(null);
		}

		public static void serialize_object_as_object( Object o, Json.Builder b ) {
			b.begin_object();

			// Iterate through properties in given object
			foreach ( ParamSpec ps in o.get_class().list_properties() ) {
				// Skip "privatized" properties
				if ( ps.name.substring( 0, 1 ) == "-" ) {
					continue;
				}

				if ( ps.get_blurb() != null && ps.get_blurb() == "ignore" ) {
					continue;
				}

				// Only serialize property if we have a serializer
				SerializeValueWrapper? serializer_wrapper = serializers[ps.value_type];
				if ( serializer_wrapper == null && ps.value_type.is_object() ) {
					serializer_wrapper = serializers[ typeof(Object) ];
				}
				if ( serializer_wrapper != null ) {
					string member_name = ps.name;
					if ( ps.get_nick() != null && ps.get_nick() != "" && ps.get_nick() != member_name ) {
						member_name = ps.get_nick();
					}
					if ( JSONConfig.transform_dash_to_underscore ) {
						member_name = member_name.replace( "-", "_" );
					}
					b.set_member_name(member_name);
					Value v = Value( ps.value_type );
					o.get_property( ps.name, ref v );
					serializer_wrapper.serializer( v, b );
				}
			}

			b.end_object();
		}

		private static void serialize_object( Value v, Json.Builder b ) {
			serialize_object_as_object( (Object) v, b );
		}

		private static void serialize_string( Value v, Json.Builder b ) {
			b.add_string_value( (string) v );
		}

		private static void serialize_int( Value v, Json.Builder b ) {
			b.add_int_value( (int) v );
		}

		private static void serialize_double( Value v, Json.Builder b ) {
			b.add_double_value( (double) v );
		}

		private static void serialize_bool( Value v, Json.Builder b ) {
			b.add_boolean_value( (bool) v );
		}

		private static void serialize_stringarray( Value v, Json.Builder b ) {
			weak string[] array = (string[]) v;
			b.begin_array();
			foreach ( var element in array ) {
				b.add_string_value(element);
			}
			b.end_array();
		}

		private static void serialize_arraylist( Value v, Json.Builder b ) {
			Type generic_type = ( (ArrayList) v ).element_type;
			b.begin_array();
			switch (generic_type.name()) {
				case "gchararray":
					ArrayList<string> array = (ArrayList<string>) v;
					foreach ( var element in array ) {
						b.add_string_value(element);
					}
					break;
				case "gint":
					ArrayList<int> array = (ArrayList<int>) v;
					foreach ( var element in array ) {
						b.add_int_value(element);
					}
					break;
				case "gboolean":
					ArrayList<bool> array = (ArrayList<bool>) v;
					foreach ( var element in array ) {
						b.add_boolean_value(element);
					}
					break;
				case "gdouble":
					ArrayList<double?> array = (ArrayList<double?>) v;
					foreach ( var element in array ) {
						b.add_double_value(element);
					}
					break;
				case "GObject":
					ArrayList<Object> array = (ArrayList<Object>) v;
					foreach ( var element in array ) {
						serialize_object_as_object( element, b );
					}
					break;
			}
			b.end_array();
		}
	}

	public class SerializeValueWrapper : Object {
		public unowned JSON.SerializeValue? serializer { get; set; }

		public SerializeValueWrapper( JSON.SerializeValue? sv ) {
			this.serializer = sv;
		}
	}

	public class JSONConfig : Object {
		/**
		 * Output "pretty" JSON, with line feeds and indentation. Default false.
		 */
		public static bool pretty_print { get; set; default = false; }

		/**
		 * Transform dashes to underscores. GLib properties use dashes instead
		 * of underscores, so a Vala property of example_property becomes
		 * example-property. This will transform it back to example_property.
		 */
		public static bool transform_dash_to_underscore { get; set; default = true; }

	}
}