/*
 * Validator.vala
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

using Gee;
namespace Ambition.Form {
	/**
	 * Provides commonly-used validators for use in forms.
	 */
	public class Validator : Object {

		/**
		 * Return true if value's length is less than or equal to max_length.
		 * @param value      String field value
		 * @param max_length Max length of field
		 * @return boolean
		 */
		public static bool max_length( string value, int max_length ) {
			return ( value.length <= max_length ? true : false );
		}

		/**
		 * Return true if value's length is greather than or equal to min_length.
		 * @param value      String field value
		 * @param min_length Min length of field
		 * @return boolean
		 */
		public static bool min_length( string value, int min_length ) {
			return ( value.length >= min_length ? true : false );
		}

		/**
		 * Return true if value is completely numeric.
		 * @param value      String field value
		 * @return boolean
		 */
		public static bool is_numeric( string value ) {
			return ( /^\-?[\d\.]+$/.match(value) && value.index_of(".") == value.last_index_of(".") ? true : false );
		}

	}
}
