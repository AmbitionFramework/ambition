/*
 * ActionMethod.vala
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

namespace Ambition {
	/**
	 * Delegate method for a controller method.
	 */
	public delegate Result ActionMethodCall( State state );

	/**
	 * Delegate method for an action filter.
	 */
	public delegate Result ActionFilterCall( State state, IActionFilter filtered_method );

	/**
	 * Wraps an ActionMethodCall.
	 */
	public class ActionMethod {
		public string? path { get; set; }

		private unowned ActionMethodCall? execute_method;
		private unowned ActionFilterCall? execute_filter;
		private IActionFilter filtered_method;
		private bool has_method { get { return ( execute_method != null ); } }
		private bool has_filter { get { return ( execute_filter != null ); } }

		/**
		 * Create a new ActionMethod with a method call and an optional path.
		 * @param am An action method
		 * @param path A path
		 */
		public ActionMethod( ActionMethodCall am, string? path = null ) {
			this.execute_method = am;
			this.path = path;
		}

		/**
		 * Create a new ActionMethod with a filter and an optional path.
		 * @param af A method filter
		 * @param filtered_object 
		 * @param path A path
		 */
		public ActionMethod.with_filter( ActionFilterCall af, IActionFilter filtered_method, string? path = null ) {
			this.execute_filter = af;
			this.filtered_method = filtered_method;
			this.path = path;
		}

		/**
		 * Execute method or filter with the given State.
		 * @param state State object
		 */
		public Result? execute( State state ) {
			if ( this.has_method ) {
				return this.execute_method(state);
			} else if ( this.has_filter ) {
				return this.execute_filter( state, this.filtered_method );
			}
			return null;
		}
	}
}