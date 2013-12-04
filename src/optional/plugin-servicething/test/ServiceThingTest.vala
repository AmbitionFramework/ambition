/*
 * ServiceThingTest.vala
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

void main (string[] args) {
	Test.init( ref args );
	add_tests();
	Test.run();
}

public static void add_tests() {
	Test.add_func("/ambition/plugin/servicething", () => {
		var plugin = new Ambition.PluginSupport.ServiceThingPlugin();
		assert( plugin != null );
		plugin.register_plugin();
	});
	Test.add_func("/ambition/plugin/servicething/serialize/json", () => {
		var json = new Ambition.PluginSupport.ServiceThing.Serializer.JSON();
		assert( json != null );
	});
	Test.add_func("/ambition/plugin/servicething/serialize/json/string", () => {
		var json = new Ambition.PluginSupport.ServiceThing.Serializer.JSON();
		string result = json.serialize( new TestStringObject() );
		assert( result != null );
		assert( result == """{"foo":"bar"}""" );
	});
	Test.add_func("/ambition/plugin/servicething/serialize/json/underscore", () => {
		Ambition.PluginSupport.ServiceThing.Serializer.JSONConfig.transform_dash_to_underscore = true;
		var json = new Ambition.PluginSupport.ServiceThing.Serializer.JSON();
		string result = json.serialize( new TestStringUnderscoreObject() );
		assert( result != null );
		assert( result == """{"foo_baz":"bar"}""" );

		Ambition.PluginSupport.ServiceThing.Serializer.JSONConfig.transform_dash_to_underscore = false;
		result = json.serialize( new TestStringUnderscoreObject() );
		assert( result != null );
		assert( result == """{"foo-baz":"bar"}""" );
	});
}

public class TestStringObject : Object {
	public string foo { get; set; default = "bar"; }
}

public class TestStringUnderscoreObject : Object {
	public string foo_baz { get; set; default = "bar"; }
}