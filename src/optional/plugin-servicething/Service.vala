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

		public ServiceMethod service_method { get; set; }

		public static HashMap<string,Serializer.ISerializer> serializers { get; set; default = new HashMap<string,Serializer.ISerializer>(); }

		class construct {
			serializers["application/json"] = new Serializer.JSON();
		}

		public Service( ServiceMethod service_method ) {
			this.service_method = service_method;
		}

		public static Result filter ( State state, IActionFilter af ) {
			Object incoming = new Object();
			Object o = ( (Service) af ).service_method( state, incoming );
			string accept_type = "application/json"; // TODO
			string result = serializers[accept_type].serialize(o);
			return new Ambition.CoreView.RawString(result);
		}
	}
}