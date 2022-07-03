/*
 * JSON.vala
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
namespace Ambition.Serializer {

	/**
	 * Serialize Service data to JSON.
	 */
	public class JSON : Object,ISerializer {
		public delegate void SerializeValue( Value v, Json.Builder b );
		public delegate bool DeserializeNode( ref Value v, Json.Node node );
		public static HashMap<Json.NodeType,DeserializeNodeWrapper> deserializers { get; set; default = new HashMap<Json.NodeType,DeserializeNodeWrapper>(); }
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
			serializers[ typeof(DateTime) ] = new SerializeValueWrapper(serialize_datetime);
			serializers[ typeof(Object) ] = new SerializeValueWrapper(serialize_object);

			deserializers[ Json.NodeType.NULL ] = new DeserializeNodeWrapper(parse_null);
			deserializers[ Json.NodeType.VALUE ] = new DeserializeNodeWrapper(parse_value);
			deserializers[ Json.NodeType.ARRAY ] = new DeserializeNodeWrapper(parse_array);
			deserializers[ Json.NodeType.OBJECT ] = new DeserializeNodeWrapper(parse_object);
		}

		public string? serialize( Object? o ) {
			if ( o == null ) {
				return null;
			}

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
					if ( ( v.fits_pointer() == false || v.peek_pointer() == null ) && ( ps.value_type.is_object() || ps.value_type.is_derived() ) ) {
						b.add_null_value();
					} else {
						serializer_wrapper.serializer( v, b );
					}
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

		private static void serialize_datetime( Value v, Json.Builder b ) {
			string iso8601 = ( (DateTime) v ).format("%Y-%m-%dT%H:%M:%S%z").replace( "+0000", "Z" );
			b.add_string_value(iso8601);
		}

		private static void serialize_stringarray( Value v, Json.Builder b ) {
			b.begin_array();
			if ( v.fits_pointer() == true ) {
				weak string[] array = (string[]) v;
				foreach ( var element in array ) {
					b.add_string_value(element);
				}
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
						if ( element != null ) {
							serialize_object_as_object( element, b );
						}
					}
					break;
				default:
					if ( generic_type.is_object() ) {
						ArrayList<Object> array = (ArrayList<Object>) v;
						foreach ( var element in array ) {
							if ( element != null ) {
								serialize_object_as_object( element, b );
							}
						}
					}
					break;
			}
			b.end_array();
		}

		public Object? deserialize( string? serialized, Type object_type ) {
			Object? o = null;
			if ( serialized != null ) {
				try {
					var parser = new Json.Parser();
					parser.load_from_data( serialized, -1 );
					var root = parser.get_root();
					Value v = Value( object_type );
					parse_object( ref v, root );
					o = v.get_object();
				} catch (Error e) {
					stderr.printf( "%s\n", e.message );
				}
			}
			return o;
		}

		public static bool parse_object( ref Value v, Json.Node node ) {
			Object o = Object.new( v.type() );
			Json.Object jo = node.get_object();
			// Iterate through properties in given object
			foreach ( ParamSpec ps in o.get_class().list_properties() ) {
				// Skip "privatized" properties
				if ( ps.name.substring( 0, 1 ) == "-" ) {
					continue;
				}

				if ( ps.get_blurb() != null && ps.get_blurb() == "ignore" ) {
					continue;
				}

				var underscored = ps.name.replace( "-", "_" );
				Json.Node? member = null;
				if ( jo.has_member(underscored) ) {
					member = jo.get_member(underscored);
				} else if ( jo.has_member( ps.name ) ) {
					member = jo.get_member( ps.name );
				}
				if ( member != null ) {
					Value member_v = Value( ps.value_type );
					if ( deserializers[ member.get_node_type() ].deserializer( ref member_v, member ) ) {
						o.set_property( ps.name, member_v );
					}
				}
			}
			v.set_object(o);
			return true;
		}

		public static bool parse_value( ref Value v, Json.Node node ) {
			var generic_type = v.type();
			switch ( generic_type.name() ) {
				case "gchararray":
					v.set_string( node.get_string() );
					break;
				case "gint":
					v.set_int( (int) node.get_int() );
					break;
				case "gint64":
					v.set_int64( node.get_int() );
					break;
				case "gboolean":
					v.set_boolean( node.get_boolean() );
					break;
				case "gdouble":
					v.set_double( node.get_double() );
					break;
				case "CouchbaseJSONNode":
					v.set_object( new Node(node) );
					break;
				default:
					return false;
			}
			return true;
		}

		public static bool parse_array( ref Value v, Json.Node node ) {
			Json.Array array = node.get_array();
			if ( array.get_length() == 0 ) {
				return false;
			}
			string type_name = v.type().name();
			if ( type_name == "GeeArrayList" ) {
				return parse_arraylist( ref v, array );
			} else if ( type_name == "GStrv" ) {
				return parse_stringarray( ref v, array );
			} else if ( type_name == "GIntv" ) {
				return parse_intarray( ref v, array );
			} else if ( type_name == "CouchbaseJSONNode" ) {
				v.set_object( new Node(node) );
				return true;
			}
			return false;
		}

		public static bool parse_null( ref Value v, Json.Node node ) {
			return false;
		}

		private static bool parse_arraylist( ref Value v, Json.Array array ) {
			Type generic_type = array.get_element(0).get_value_type();
			switch (generic_type.name()) {
				case "gchararray":
					ArrayList<string> new_array = new ArrayList<string>();
					array.foreach_element(
						( array, index, node ) => {
							new_array.add( node.get_string() );
						}
					);
					v.set_object(new_array);
					return true;
				case "gint":
					ArrayList<int> new_array = new ArrayList<int>();
					array.foreach_element(
						( array, index, node ) => {
							new_array.add( (int) node.get_int() );
						}
					);
					v.set_object(new_array);
					return true;
				case "gint64":
					ArrayList<int64?> new_array = new ArrayList<int64?>();
					array.foreach_element(
						( array, index, node ) => {
							new_array.add( node.get_int() );
						}
					);
					v.set_object(new_array);
					return true;
				case "gdouble":
					ArrayList<double?> new_array = new ArrayList<double?>();
					array.foreach_element(
						( array, index, node ) => {
							new_array.add( node.get_double() );
						}
					);
					v.set_object(new_array);
					return true;
				default:
					if ( generic_type.is_object() ) {
						ArrayList<Object> new_array = new ArrayList<Object>();
						array.foreach_element(
							( array, index, node ) => {
								Value obj_v = Value(generic_type);
								parse_object( ref obj_v, node );
								new_array.add( (Object) obj_v );
							}
						);
						v.set_object(new_array);
						return true;
					}
					break;
			}
			return false;
		}

		private static bool parse_stringarray( ref Value v, Json.Array array ) {
			string[] new_array = new string[ array.get_length() ];
			array.foreach_element(
				( array, index, node ) => {
					new_array[index] = node.get_string();
				}
			);
			v.set_boxed(new_array);
			return true;
		}

		private static bool parse_intarray( ref Value v, Json.Array array ) {
			int[] new_array = new int[ array.get_length() ];
			array.foreach_element(
				( array, index, node ) => {
					new_array[index] = (int) node.get_int();
				}
			);
			v.set_boxed(new_array);
			return true;
		}
	}

	public class DeserializeNodeWrapper : Object {
		public unowned JSON.DeserializeNode? deserializer { get; set; }

		public DeserializeNodeWrapper( JSON.DeserializeNode? dn ) {
			this.deserializer = dn;
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
