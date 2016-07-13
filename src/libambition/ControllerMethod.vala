/*
 * ControllerMethod.vala
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

using Gee;
using Ambition.Serializer;
namespace Ambition {
	/**
	 * Delegate method for a controller method expecting a State and returning a
	 * Result.
	 */
	public delegate Result ControllerMethodStateResult( State state );

	/**
	 * Delegate method for a controller method expecting a State and a marshaled
	 * object and returning a Result.
	 */
	public delegate Result ControllerMethodObjectResult( State state, Object? o );

	/**
	 * Delegate method for a controller method expecting a State and a marshaled
	 * object and returning an Object.
	 */
	public delegate Object? ControllerMethodObjectObject( State state, Object? o );

	public class ControllerMethod : Object {
		public enum MethodType {
			CMSR,
			CMOR,
			CMOO
		}

		public MethodType controller_method_type;
		public ControllerMethodStateResult cmsr;
		public ControllerMethodObjectResult cmor;
		public ControllerMethodObjectObject cmoo;
		public Route route;

		public ControllerMethod.with_state_result( Route r, ControllerMethodStateResult m ) {
			this.controller_method_type = MethodType.CMSR;
			this.cmsr = m;
			this.route = r;
		}

		public ControllerMethod.with_object_result( Route r, ControllerMethodObjectResult m ) {
			this.controller_method_type = MethodType.CMOR;
			this.cmor = m;
			this.route = r;
		}

		public ControllerMethod.with_object_object( Route r, ControllerMethodObjectObject m ) {
			this.controller_method_type = MethodType.CMOO;
			this.cmoo = m;
			this.route = r;
		}

		public Result? execute( State state ) {
			switch(controller_method_type) {
				case MethodType.CMSR:
					return execute_cmsr(state);

				case MethodType.CMOR:
					return execute_cmor(state);

				case MethodType.CMOO:
					return execute_cmoo(state);
			}

			// If this is constructed normally, this won't happen. If it is not,
			// well.
			return null;
		}

		private Result execute_cmsr( State state ) {
			return cmsr(state);
		}

		private Result execute_cmor( State state ) {
			return null;
		}

		private Result execute_cmoo( State state ) {
			return null;
		}
	}
}
