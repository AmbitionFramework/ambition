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
	 * Wraps an ActionMethodCall.
	 */
	public class ActionMethod {
		public unowned ActionMethodCall execute { get; set; }
		public string? path { get; set; }

		/**
		 * Create a new ActionMethod with a method call and an optional path.
		 * @param am An action method
		 * @param path A path
		 */
		public ActionMethod( ActionMethodCall am, string? path = null ) {
			this.execute = am;
			this.path = path;
		}
	}
}