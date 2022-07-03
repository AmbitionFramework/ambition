/*
 * serializer_responsehelper.vala
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

public class SerializerResponseHelperTest : Ambition.Testing.AbstractTestCase {
	public SerializerResponseHelperTest() {
		base("Ambition.Serializer.ResponseHelper");
		add_test( "bad_request", bad_request );
		add_test( "unauthenticated", unauthenticated );
		add_test( "forbidden", forbidden );
		add_test( "not_found", not_found );
		add_test( "method_not_allowed", method_not_allowed );
		add_test( "unsupported_media_type", unsupported_media_type );
		add_test( "failure", failure );
	}

	public void bad_request() {
		Ambition.Config.set_value( "default_accept_type", "application/json" );
		var state = get_state();
		Object o = Ambition.Serializer.ResponseHelper.bad_request(state);
		assert( o != null );
		var result = get_controller_method().determine_serialize( state, o );
		assert( result != null );
		assert( state.response.status == 400 );
		assert( """"code":400""" in result );
		assert( """"message":"Bad Request"""" in result );
		Ambition.Config.reset();
	}

	public void unauthenticated() {
		Ambition.Config.set_value( "default_accept_type", "application/json" );
		var state = get_state();
		Object o = Ambition.Serializer.ResponseHelper.unauthenticated(state);
		assert( o != null );
		var result = get_controller_method().determine_serialize( state, o );
		assert( result != null );
		assert( state.response.status == 401 );
		assert( """"code":401""" in result );
		assert( """"message":"Unauthenticated"""" in result );
		Ambition.Config.reset();
	}

	public void forbidden() {
		Ambition.Config.set_value( "default_accept_type", "application/json" );
		var state = get_state();
		Object o = Ambition.Serializer.ResponseHelper.forbidden(state);
		assert( o != null );
		var result = get_controller_method().determine_serialize( state, o );
		assert( result != null );
		assert( state.response.status == 403 );
		assert( """"code":403""" in result );
		assert( """"message":"Forbidden"""" in result );
		Ambition.Config.reset();
	}

	public void not_found() {
		Ambition.Config.set_value( "default_accept_type", "application/json" );
		var state = get_state();
		Object o = Ambition.Serializer.ResponseHelper.not_found(state);
		assert( o != null );
		var result = get_controller_method().determine_serialize( state, o );
		assert( result != null );
		assert( state.response.status == 404 );
		assert( """"code":404""" in result );
		assert( """"message":"Not Found"""" in result );
		Ambition.Config.reset();
	}

	public void method_not_allowed() {
		Ambition.Config.set_value( "default_accept_type", "application/json" );
		var state = get_state();
		Object o = Ambition.Serializer.ResponseHelper.method_not_allowed(state);
		assert( o != null );
		var result = get_controller_method().determine_serialize( state, o );
		assert( result != null );
		assert( state.response.status == 405 );
		assert( """"code":405""" in result );
		assert( """"message":"Method Not Allowed"""" in result );
		Ambition.Config.reset();
	}

	public void unsupported_media_type() {
		Ambition.Config.set_value( "default_accept_type", "application/json" );
		var state = get_state();
		Object o = Ambition.Serializer.ResponseHelper.unsupported_media_type(state);
		assert( o != null );
		var result = get_controller_method().determine_serialize( state, o );
		assert( result != null );
		assert( state.response.status == 415 );
		assert( """"code":415""" in result );
		assert( """"message":"Unsupported Media Type"""" in result );
		Ambition.Config.reset();
	}

	public void failure() {
		Ambition.Config.set_value( "default_accept_type", "application/json" );
		var state = get_state();
		Object o = Ambition.Serializer.ResponseHelper.failure(state);
		assert( o != null );
		var result = get_controller_method().determine_serialize( state, o );
		assert( result != null );
		assert( state.response.status == 500 );
		assert( """"code":500""" in result );
		assert( """"message":"Server Error"""" in result );
		Ambition.Config.reset();
	}

	private static Ambition.ControllerMethod get_controller_method() {
		var route = new Ambition.Route();
		route.marshal_response( "application/filemaker", new Ambition.Serializer.HTML() );
		route.marshal_json( ( new Object() ).get_type() );
		var cm = new Ambition.ControllerMethod.with_object_object( route, example_state_object_object_method );
		return cm;
	}


	public static Object? example_state_object_object_method( Ambition.State state, Object? o ) {
		return null;
	}
}
