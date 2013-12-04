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
	public delegate void SerializeValue( Value v, Json.Builder b );

	public class JSON : Object,ISerializer {
		public HashMap<Type,SerializeValueWrapper> serializers { get; set; default = new HashMap<Type,SerializeValueWrapper>(); }

		public JSON() {
			serializers[ typeof(string) ] = new SerializeValueWrapper(serialize_string);
		}

		public string? serialize( Object o ) {
			Json.Builder builder = new Json.Builder();
			builder.begin_object();

			// Iterate through properties in given object
			foreach ( ParamSpec ps in o.get_class().list_properties() ) {
				// Skip "privatized" properties
				if ( ps.name.substring( 0, 1 ) == "-" ) {
					continue;
				}

				// Only serialize property if we have a serializer
				SerializeValueWrapper? serializer_wrapper = serializers[ps.value_type];
				if ( serializer_wrapper != null ) {
					string member_name = ps.name;
					if ( JSONConfig.transform_dash_to_underscore ) {
						member_name = ps.name.replace( "-", "_" );
					}
					builder.set_member_name(member_name);
					Value v = Value( ps.value_type );
					o.get_property( ps.name, ref v );
					serializer_wrapper.serializer( v, builder );
				}
			}

			builder.end_object();
			var generator = new Json.Generator();
			var root = builder.get_root();
			generator.set_root(root);
			return generator.to_data(null);
		}

		private static void serialize_string( Value v, Json.Builder b ) {
			b.add_string_value( v.get_string() );
		}
	}

	public class SerializeValueWrapper : Object {
		public SerializeValue serializer { get; set; }

		public SerializeValueWrapper( SerializeValue sv ) {
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