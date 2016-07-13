/*
 * action.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2016 Sensical, Inc.
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

public class ActionTest : Ambition.Testing.AbstractTestCase {
	public ActionTest() {
		base("Ambition.Action");
		add_test( "init", init );
		add_test( "method", method );
		add_test( "target", target );
		add_test( "target_or", target_or );
		add_test( "target_oo", target_oo );
		add_test( "path", path );
		add_test( "marshal_request", marshal_request );
		add_test( "marshal_response", marshal_response );
		add_test( "action_info", action_info );
	}

	public void init() {
		var obj = new Ambition.Action();
		assert( obj != null );
	}

	public void method() {
		var a = new Ambition.Action();
		var b = a.method( Ambition.HttpMethod.POST );
		assert( a.methods.size == 1 );
		assert( a.methods[0] == Ambition.HttpMethod.POST );
		assert( a == b );
	}

	public void target() {
		var a = new Ambition.Action();
		var b = a.target( example_state_result_method );
		assert( a.targets.size == 1 );
		assert( a.targets[0] is Ambition.ControllerMethod );
		assert( a.targets[0].controller_method_type == Ambition.ControllerMethod.MethodType.CMSR );
		assert( a == b );
	}

	public void target_or() {
		var a = new Ambition.Action();
		var b = a.target_object_result( example_state_object_result_method );
		assert( a.targets.size == 1 );
		assert( a.targets[0] is Ambition.ControllerMethod );
		assert( a.targets[0].controller_method_type == Ambition.ControllerMethod.MethodType.CMOR );
		assert( a == b );
	}

	public void target_oo() {
		var a = new Ambition.Action();
		var b = a.target_object_object( example_state_object_object_method );
		assert( a.targets.size == 1 );
		assert( a.targets[0] is Ambition.ControllerMethod );
		assert( a.targets[0].controller_method_type == Ambition.ControllerMethod.MethodType.CMOO );
		assert( a == b );
	}

	public void path() {
		var a = new Ambition.Action();
		var b = a.path("/foo/bar");
		assert( a.paths.size == 1 );
		assert( a.paths[0] == "/foo/bar" );
		assert( a == b );
	}

	public void path_respond() {
		var a = new Ambition.Action()
					.path("/foo/[baz]/bar")
					.method( Ambition.HttpMethod.GET );

		assert( a.paths.size == 1 );
		assert( a.paths[0] == "/foo/[baz]/bar" );
		assert( a.responds_to_request( "/foo/123/bar", Ambition.HttpMethod.GET ) == true );
		assert( a.responds_to_request( "/foo/abcdef/bar", Ambition.HttpMethod.GET ) == true );
		assert( a.responds_to_request( "/foo/bar", Ambition.HttpMethod.GET ) == false );
	}

	public void marshal_request() {
		var a = new Ambition.Action();
		var b = a.marshal_request( new Ambition.Serializer.HTML(), a.get_type() );
		var c = a.request_marshaller;
		assert( c != null );
		assert( c.serializer is Ambition.Serializer.HTML );
		assert( a == b );
	}

	public void marshal_response() {
		var a = new Ambition.Action();
		var b = a.marshal_response( a.get_type(), new Ambition.Serializer.HTML() );
		var c = a.response_marshaller;
		assert( c != null );
		assert( c.serializer is Ambition.Serializer.HTML );
		assert( a == b );
	}

	public void action_info() {
		var a = new Ambition.Action()
					.path("/foo/[baz]/bar")
					.method( Ambition.HttpMethod.GET )
					.target(example_state_result_method);
		assert( a != null );
		var info = a.action_info();
		assert( info == "                           GET /foo/[baz]/bar --> 1 target" );
		a.method( Ambition.HttpMethod.POST );
		a.target_object_result(example_state_object_result_method);
		info = a.action_info();
		assert( info == "                     GET, POST /foo/[baz]/bar --> 2 targets" );
	}

	public static Ambition.Result example_state_result_method( Ambition.State state ) {
		return new Ambition.CoreView.None();
	}

	public static Ambition.Result example_state_object_result_method( Ambition.State state, Object? o ) {
		return new Ambition.CoreView.None();
	}

	public static Object? example_state_object_object_method( Ambition.State state, Object? o ) {
		return null;
	}
}
