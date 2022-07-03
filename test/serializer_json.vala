/*
 * serializer_json.vala
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

public class SerializerJsonTest : Object {
	public static void add_tests() {
		Test.add_func("/ambition/serializer/json/serialize", () => {
			var json = new Ambition.Serializer.JSON();
			assert( json != null );
		});
		Test.add_func("/ambition/serializer/json/serialize/string", () => {
			var json = new Ambition.Serializer.JSON();
			string result = json.serialize( new TestStringObject() );
			assert( result != null );
			assert( result == """{"foo":"bar"}""" );
		});
		Test.add_func("/ambition/serializer/json/serialize/underscore", () => {
			Ambition.Serializer.JSONConfig.transform_dash_to_underscore = true;
			var json = new Ambition.Serializer.JSON();
			string result = json.serialize( new TestStringUnderscoreObject() );
			assert( result != null );
			assert( result == """{"foo_baz":"bar"}""" );

			Ambition.Serializer.JSONConfig.transform_dash_to_underscore = false;
			result = json.serialize( new TestStringUnderscoreObject() );
			assert( result != null );
			assert( result == """{"foo-baz":"bar"}""" );


			Ambition.Serializer.JSONConfig.transform_dash_to_underscore = true;
		});
		Test.add_func("/ambition/serializer/json/serialize/int", () => {
			var json = new Ambition.Serializer.JSON();
			string result = json.serialize( new TestIntObject() );
			assert( result != null );
			assert( result == """{"foo":42}""" );
		});
		Test.add_func("/ambition/serializer/json/serialize/double", () => {
			var json = new Ambition.Serializer.JSON();
			string result = json.serialize( new TestDoubleObject() );
			assert( result != null );
			assert( """{"foo":62.31""" in result ); // Double precision issue?
		});
		Test.add_func("/ambition/serializer/json/serialize/bool", () => {
			var json = new Ambition.Serializer.JSON();
			string result = json.serialize( new TestBoolObject() );
			assert( result != null );
			assert( result == """{"foo":true}""" );
		});
		Test.add_func("/ambition/serializer/json/serialize/string_array", () => {
			var json = new Ambition.Serializer.JSON();
			string result = json.serialize( new TestStringArrayObject() );
			assert( result != null );
			assert( result == """{"foo":["bar","baz"]}""" );
		});
		Test.add_func("/ambition/serializer/json/serialize/string_arraylist", () => {
			var json = new Ambition.Serializer.JSON();
			string result = json.serialize( new TestStringArrayListObject() );
			assert( result != null );
			assert( result == """{"foo":["bar","baz"]}""" );
		});
		Test.add_func("/ambition/serializer/json/serialize/object", () => {
			var json = new Ambition.Serializer.JSON();
			string result = json.serialize( new TestObjectObject() );
			assert( result != null );
			assert( result == """{"bar":{"foo":["bar","baz"]}}""" );
		});
		Test.add_func("/ambition/serializer/json/serialize/everything", () => {
			var json = new Ambition.Serializer.JSON();
			string result = json.serialize( new TestEverythingObject() );
			assert( result != null );
			assert( result == """{"foo_baz":"bar","some_int":42,"is_something":false,"list_of_things":["thing","another","so wow"],"super_container":{"container":{"foo":["bar","baz"]},"example":"I am here"}}""" );
		});
		Test.add_func("/ambition/serializer/json/serialize/ignore", () => {
			var json = new Ambition.Serializer.JSON();
			string result = json.serialize( new TestIgnoreObject() );
			assert( result != null );
			assert( result == """{"not_ignored":"woohoo"}""" );
		});
		Test.add_func("/ambition/serializer/json/serialize/rename", () => {
			var json = new Ambition.Serializer.JSON();
			string result = json.serialize( new TestRenameObject() );
			assert( result != null );
			assert( result == """{"renamed":"woohoo"}""" );
		});
		Test.add_func("/ambition/serializer/json/deserialize", () => {
			var json = new Ambition.Serializer.JSON();
			assert( json != null );
		});
	}
}

