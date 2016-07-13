/*
 * controllermethod.vala
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

public class ControllerMethodTest : Ambition.Testing.AbstractTestCase {
	private Ambition.Route r = new Ambition.Route();

	public ControllerMethodTest() {
		base("Ambition.ControllerMethod");
		add_test( "init_with_state_result", init_with_state_result );
		add_test( "init_with_object_result", init_with_object_result );
		add_test( "init_with_object_object", init_with_object_object );
		add_test( "parse_accept_html", parse_accept_html );
		add_test( "parse_accept_html_ordering", parse_accept_html_ordering );
		add_test( "parse_accept_json", parse_accept_json );
		add_test( "parse_accept_xml", parse_accept_xml );
		add_test( "parse_accept_nothing", parse_accept_nothing );
		add_test( "parse_accept_default", parse_accept_default );
		add_test( "determine_serialize_bad", determine_serialize_bad );
		add_test( "get_object_from_state", get_object_from_state );
	}

	public void init_with_state_result() {
		var obj = new Ambition.ControllerMethod.with_state_result( r, example_state_result_method );
		assert( obj != null );
		assert( obj.controller_method_type == Ambition.ControllerMethod.MethodType.CMSR );
		assert( obj.cmsr != null );
		assert( obj.cmor == null );
		assert( obj.cmoo == null );
	}

	public void init_with_object_result() {
		var obj = new Ambition.ControllerMethod.with_object_result( r, example_state_object_result_method );
		assert( obj != null );
		assert( obj.controller_method_type == Ambition.ControllerMethod.MethodType.CMOR );
		assert( obj.cmsr == null );
		assert( obj.cmor != null );
		assert( obj.cmoo == null );
	}

	public void init_with_object_object() {
		var obj = new Ambition.ControllerMethod.with_object_object( r, example_state_object_object_method );
		assert( obj != null );
		assert( obj.controller_method_type == Ambition.ControllerMethod.MethodType.CMOO );
		assert( obj.cmsr == null );
		assert( obj.cmor == null );
		assert( obj.cmoo != null );
	}

	public void parse_accept_html() {
		var r = ( new Ambition.Route() ).marshal_response( "text/html", new Ambition.Serializer.HTML() );
		var obj = new Ambition.ControllerMethod.with_object_result( r, example_state_object_result_method );
		assert( obj != null );

		string accept_header_1 = "text/*;q=0.3, text/html;q=0.7, text/html;level=1, text/html;level=2;q=0.4, */*;q=0.5";
		string result = obj.parse_accept_header(accept_header_1);
		assert( result != null );
		assert( result == "text/html" );
	}

	public void parse_accept_html_ordering() {
		var r = ( new Ambition.Route() ).marshal_response( "text/html", new Ambition.Serializer.HTML() );
		var obj = new Ambition.ControllerMethod.with_object_result( r, example_state_object_result_method );
		assert( obj != null );

		string accept_header_2 = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8,application/json";
		var result = obj.parse_accept_header(accept_header_2);
		assert( result != null );
		assert( result == "text/html" );
	}

	public void parse_accept_json() {
		var r = ( new Ambition.Route() ).marshal_response( "application/json", new Ambition.Serializer.JSON() );
		var obj = new Ambition.ControllerMethod.with_object_result( r, example_state_object_result_method );
		assert( obj != null );

		string accept_header_3 = "application/json,text/html,application/xhtml+xml,application/xml;q=0.9";
		var result = obj.parse_accept_header(accept_header_3);
		assert( result != null );
		assert( result == "application/json" );
	}

	public void parse_accept_xml() {
		var r = ( new Ambition.Route() ).marshal_response( "application/xml", new Ambition.Serializer.JSON() );
		var obj = new Ambition.ControllerMethod.with_object_result( r, example_state_object_result_method );
		assert( obj != null );

		string accept_header_4 = "application/json;q=0.8,text/html;q=0.5,application/xhtml+xml,application/xml;q=0.9";
		var result = obj.parse_accept_header(accept_header_4);
		assert( result != null );
		assert( result == "application/xml" );
	}

	public void parse_accept_nothing() {
		var r = ( new Ambition.Route() ).marshal_json( this.get_type() );
		var obj = new Ambition.ControllerMethod.with_object_result( r, example_state_object_result_method );
		assert( obj != null );

		string accept_header_5 = "application/jsv;q=0.8,text/plain;q=0.5,application/xhtml+xml,application/filemaker;q=0.9";
		var result = obj.parse_accept_header(accept_header_5);
		assert( result == null );
	}

	public void parse_accept_default() {
		Ambition.Config.set_value("default_accept_type", "application/json");
		var r = ( new Ambition.Route() ).marshal_json( this.get_type() );
		var obj = new Ambition.ControllerMethod.with_object_result( r, example_state_object_result_method );
		assert( obj != null );

		string accept_header_5 = "application/jsv;q=0.8,text/plain;q=0.5,application/xhtml+xml,application/filemaker;q=0.9";
		var result = obj.parse_accept_header(accept_header_5);
		assert( result != null );
		assert( result == "application/json" );
		Ambition.Config.reset();
	}

	public void determine_serialize_bad() {
		var obj = new Ambition.ControllerMethod.with_object_result( r, example_state_object_result_method );
		var state = get_state();
		var result = obj.determine_serialize( state, new Object() );
		assert( state.response.status == 415 );
	}

	public void get_object_from_state() {
		var r = ( new Ambition.Route() ).marshal_json( ( new TestStringObject() ).get_type() );
		var obj = new Ambition.ControllerMethod.with_object_object( r, example_state_object_result_method );
		var state = get_state();

		Object? o = obj.get_object_from_state(state);
		assert( o == null );

		state.request.content_type = "application/json";
		uint8[] bytes = { '{', '"', 'f', 'o', 'o', '"',  ':', '"', 'b', 'a', 'r', '"', '}', '\0' };
		state.request.request_body = bytes;
		o = obj.get_object_from_state(state);
		assert( o != null );
		TestStringObject tso = (TestStringObject) o;
		assert( tso != null );
		assert( tso.foo == "bar" );
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

private static Ambition.State get_state() {
	var state = new Ambition.State("test");
	state.request = new Ambition.Request();
	state.request.headers = new Gee.HashMap<string,string>();
	state.response = new Ambition.Response();
	return state;
}