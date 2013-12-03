/*
 * actionbuilder.vala
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

public class ActionBuilderTest {
	public static const string action_1 = "/                               GET      Root.index";
	public static const string action_2 = "/example/path                   GET,POST Root.begin, Root.index";
	public static const string action_3 = "/foo/[page]/bar                 GET      Foo.bar";
	public static const string action_4 = "/categories/baz                 GET      Service:Foo.baz";

	public static void add_tests() {
		Test.add_func("/ambition/actionbuilder/init", () => {
			var a = new Ambition.ActionBuilder();
			assert( a != null );
		});
		Test.add_func("/ambition/actionbuilder/normalize_controller", () => {
			var a = new Ambition.ActionBuilder();
			assert( a.normalize_controller("Root") == "root" );
			assert( a.normalize_controller("TestController") == "testcontroller" );
			assert( a.normalize_controller("Actions.Testing") == "actions_testing" );
			assert( a.normalize_controller("nonCompliant_Tester") == "noncompliant_tester" );
		});
		Test.add_func("/ambition/actionbuilder/is_valid_action_line/1", () => {
			var a = new Ambition.ActionBuilder();

			assert( a.is_valid_action_line(action_1) != null );
		});
		Test.add_func("/ambition/actionbuilder/is_valid_action_line/2", () => {
			var a = new Ambition.ActionBuilder();

			assert( a.is_valid_action_line(action_2) != null );
		});
		Test.add_func("/ambition/actionbuilder/is_valid_action_line/3", () => {
			var a = new Ambition.ActionBuilder();

			assert( a.is_valid_action_line(action_3) != null );
		});
		Test.add_func("/ambition/actionbuilder/parse_action_line", () => {
			var a = new Ambition.ActionBuilder();

			var controllers = new Gee.HashSet<string>();
			string result = a.parse_action_line( action_1, controllers );
			assert( result != null );
			assert( controllers.size == 1 );
			assert( controllers.contains("Root") );
			assert( "root.index" in result );
			assert( result == """( new Ambition.Action() ).regex(/^\/$/).allow_method( HttpMethod.GET ).add_target_method( new Ambition.ActionMethod( root.index, "/root/index" ) )""" );
		});
		Test.add_func("/ambition/actionbuilder/parse_action_line/filter", () => {
			var a = new Ambition.ActionBuilder();

			var controllers = new Gee.HashSet<string>();
			string result = a.parse_action_line( action_4, controllers );
			assert( result != null );
			assert( controllers.size == 1 );
			assert( controllers.contains("Foo") );
			assert( "foo.baz" in result );
			assert( result == """( new Ambition.Action() ).regex(/^\/categories\/baz\/?$/).allow_method( HttpMethod.GET ).add_target_method( new Ambition.ActionMethod.with_filter( Ambition.Filter.Service.filter, new Ambition.Filter.Service(foo.baz), "/foo/baz" ) )""" );
		});
		Test.add_func("/ambition/actionbuilder/build_action_block", () => {
			var a = new Ambition.ActionBuilder();

			var controllers = new Gee.HashSet<string>();
			var actions = new Gee.ArrayList<string>();
			actions.add( a.parse_action_line( action_1, controllers ) );
			actions.add( a.parse_action_line( action_2, controllers ) );
			actions.add( a.parse_action_line( action_3, controllers ) );

			assert( controllers.size == 2 );

			string block = a.build_action_block( controllers, actions );
			assert( block != null );
			assert( "var foo = new Controller.Foo();" in block );
			assert( "var root = new Controller.Root();" in block );
			assert( "Ambition.Action[] actions = {" in block );
			assert( "return actions;" in block );
		});
	}
}