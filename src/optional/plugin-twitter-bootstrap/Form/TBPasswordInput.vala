/*
 * TBPasswordInput.vala
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

namespace Ambition.Form {
	/**
	 * <input type="password" />
	 */
	public class TBPasswordInput : TBTextInput {
		public TBPasswordInput() {
			this.input_type = "password";
		}

		/**
		 * Create a TBPasswordInput with a predefined class attribute.
		 * @param class_attribute One or more classes
		 */
		public TBPasswordInput.with_class( string class_attribute ) {
			this();
			this.class_attribute = class_attribute;
		}
	}
}
