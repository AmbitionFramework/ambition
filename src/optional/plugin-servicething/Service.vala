/*
 * Service.vala
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
using Ambition.PluginSupport.ServiceThing;
namespace Ambition.Filter {
	public class Service : Object,IActionFilter {

		public delegate Object ServiceMethod( State state, Object o );

		public unowned ServiceMethod? service_method { get; set; }

		public static HashMap<string,Serializer.ISerializer> serializers { get; set; }

		class construct {
			serializers = new HashMap<string,Serializer.ISerializer>();
			serializers["application/json"] = new Serializer.JSON();
			serializers["application/xml"] = new Serializer.XML();
			serializers["text/xml"] = serializers["application/xml"];
			serializers["text/json"] = serializers["application/json"];
			serializers["text/html"] = new Serializer.HTML();
		}

		public Service( ServiceMethod? service_method ) {
			this.service_method = service_method;
		}

		public static Result filter ( State state, IActionFilter af ) {
			Object incoming = new Object();
			Object o = ( (Service) af ).service_method( state, incoming );
			string accept_type = "text/html";
			var headers = state.request.headers;
			if ( headers.has_key("Accept") ) {
				string best_accept_type = parse_accept_header( headers["Accept"] );
				if ( best_accept_type != null ) {
					accept_type = best_accept_type;
				}
			}
			string result = serializers[accept_type].serialize(o);
			return new Ambition.CoreView.RawString(result);
		}

		/**
		 * Parse the Accept header, and choose the best media type based on
		 * available serializers.
		 * @param accept_header Original HTTP Accept header
		 */
		public static string? parse_accept_header( string accept_header ) {
			var accept_list = new ArrayList<string>();
			foreach ( var accept_dirty in accept_header.split(",") ) {
				var accept = accept_dirty.replace( " ", "" );
				string q = "1.0";
				if ( ";" in accept ) {
					string[] accept_pair = accept.split(";");
					accept = accept_pair[0];
					for ( int i = 1; i < accept_pair.length; i++ ) {
						string[] qualifier = accept_pair[i].split("=");
						if ( qualifier[0] == "q" ) {
							q = qualifier[1];
						}
					}
				}
				accept_list.add( "%s|%s".printf( q, accept ) );
			}
			// TODO: Holy crap, I hate this.
			// Sort by q, in reverse order
			accept_list.sort(
				(a, b) => {
					string[] a_array = a.split("|");
					string[] b_array = b.split("|");
					double aa = double.parse(a_array[0]);
					double bb = double.parse(b_array[0]);
					if ( aa == bb ) return 0;
					if ( aa > bb )  return -1;
					return 1;
				}
			);
			foreach ( var accept_combo_string in accept_list ) {
				string[] accept_combo = accept_combo_string.split("|");
				if ( serializers.has_key( accept_combo[1] ) ) {
					return accept_combo[1];
				}
			}
			return null;
		}
	}
}