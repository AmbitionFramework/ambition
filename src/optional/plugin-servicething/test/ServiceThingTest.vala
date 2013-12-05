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
	Test.add_func("/ambition/plugin/servicething/parse_accept", () => {
		var service = new Ambition.Filter.Service(null);
		assert( service != null );
		assert( Ambition.Filter.Service.serializers != null );

		string accept_header_1 = "text/*;q=0.3, text/html;q=0.7, text/html;level=1, text/html;level=2;q=0.4, */*;q=0.5";
		string result = Ambition.Filter.Service.parse_accept_header(accept_header_1);
		assert( result != null );
		assert( result == "text/html" );

		string accept_header_2 = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8,application/json";
		result = Ambition.Filter.Service.parse_accept_header(accept_header_2);
		assert( result != null );
		assert( result == "text/html" );

		string accept_header_3 = "application/json,text/html,application/xhtml+xml,application/xml;q=0.9";
		result = Ambition.Filter.Service.parse_accept_header(accept_header_3);
		assert( result != null );
		assert( result == "application/json" );

		string accept_header_4 = "application/json;q=0.8,text/html;q=0.5,application/xhtml+xml,application/xml;q=0.9";
		result = Ambition.Filter.Service.parse_accept_header(accept_header_4);
		assert( result != null );
		assert( result == "application/xml" );

		string accept_header_5 = "application/jsv;q=0.8,text/plain;q=0.5,application/xhtml+xml,application/filemaker;q=0.9";
		result = Ambition.Filter.Service.parse_accept_header(accept_header_5);
		assert( result == null );
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


		Ambition.PluginSupport.ServiceThing.Serializer.JSONConfig.transform_dash_to_underscore = true;
	});
	Test.add_func("/ambition/plugin/servicething/serialize/json/int", () => {
		var json = new Ambition.PluginSupport.ServiceThing.Serializer.JSON();
		string result = json.serialize( new TestIntObject() );
		assert( result != null );
		assert( result == """{"foo":42}""" );
	});
	Test.add_func("/ambition/plugin/servicething/serialize/json/double", () => {
		var json = new Ambition.PluginSupport.ServiceThing.Serializer.JSON();
		string result = json.serialize( new TestDoubleObject() );
		assert( result != null );
		assert( """{"foo":62.31""" in result ); // Double precision issue?
	});
	Test.add_func("/ambition/plugin/servicething/serialize/json/bool", () => {
		var json = new Ambition.PluginSupport.ServiceThing.Serializer.JSON();
		string result = json.serialize( new TestBoolObject() );
		assert( result != null );
		assert( result == """{"foo":true}""" );
	});
	Test.add_func("/ambition/plugin/servicething/serialize/json/string_array", () => {
		var json = new Ambition.PluginSupport.ServiceThing.Serializer.JSON();
		string result = json.serialize( new TestStringArrayObject() );
		assert( result != null );
		assert( result == """{"foo":["bar","baz"]}""" );
	});
	Test.add_func("/ambition/plugin/servicething/serialize/json/string_arraylist", () => {
		var json = new Ambition.PluginSupport.ServiceThing.Serializer.JSON();
		string result = json.serialize( new TestStringArrayListObject() );
		assert( result != null );
		assert( result == """{"foo":["bar","baz"]}""" );
	});
	Test.add_func("/ambition/plugin/servicething/serialize/json/object", () => {
		var json = new Ambition.PluginSupport.ServiceThing.Serializer.JSON();
		string result = json.serialize( new TestObjectObject() );
		assert( result != null );
		assert( result == """{"bar":{"foo":["bar","baz"]}}""" );
	});
	Test.add_func("/ambition/plugin/servicething/serialize/json/everything", () => {
		var json = new Ambition.PluginSupport.ServiceThing.Serializer.JSON();
		string result = json.serialize( new TestEverythingObject() );
		assert( result != null );
		assert( result == """{"foo_baz":"bar","some_int":42,"is_something":false,"list_of_things":["thing","another","so wow"],"super_container":{"container":{"foo":["bar","baz"]},"example":"I am here"}}""" );
	});
	Test.add_func("/ambition/plugin/servicething/serialize/json/ignore", () => {
		var json = new Ambition.PluginSupport.ServiceThing.Serializer.JSON();
		string result = json.serialize( new TestIgnoreObject() );
		assert( result != null );
		assert( result == """{"not_ignored":"woohoo"}""" );
	});
	Test.add_func("/ambition/plugin/servicething/serialize/json/rename", () => {
		var json = new Ambition.PluginSupport.ServiceThing.Serializer.JSON();
		string result = json.serialize( new TestRenameObject() );
		assert( result != null );
		assert( result == """{"renamed":"woohoo"}""" );
	});
}

public class TestStringObject : Object {
	public string foo { get; set; default = "bar"; }
}

public class TestStringUnderscoreObject : Object {
	public string foo_baz { get; set; default = "bar"; }
}

public class TestIntObject : Object {
	public int foo { get; set; default = 42; }
}

public class TestDoubleObject : Object {
	public double foo { get; set; default = 62.31; }
}

public class TestBoolObject : Object {
	public bool foo { get; set; default = true; }
}

public class TestStringArrayObject : Object {
	public string[] foo { get; set; default = { "bar", "baz" }; }
}

public class TestStringArrayListObject : Object {
	public Gee.ArrayList<string> foo { get; set; default = new Gee.ArrayList<string>(); }

	public TestStringArrayListObject() {
		foo.add("bar");
		foo.add("baz");
	}
}

public class TestObjectObject : Object {
	public Object bar { get; set; default = new TestStringArrayObject(); }
}

public class TestEverythingObject : Object {
	public string foo_baz { get; set; default = "bar"; }
	public int some_int { get; set; default = 42; }
	public bool is_something { get; set; default = false; }
	public string[] list_of_things { get; set; default = { "thing", "another", "so wow" }; }
	public Object super_container { get; set; default = new TestEverythingContainerObject(); }
}

public class TestEverythingContainerObject : Object {
	public Object container { get; set; default = new TestStringArrayListObject(); }
	public string example { get; set; default = "I am here"; }
}

public class TestIgnoreObject : Object {
	public string not_ignored { get; set; default = "woohoo"; }
	[Description( blurb = "ignore" )]
	public string ignored { get; set; default = "boo"; }
}

public class TestRenameObject : Object {
	[Description( nick = "renamed" )]
	public string something { get; set; default = "woohoo"; }
}
