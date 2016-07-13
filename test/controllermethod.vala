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
