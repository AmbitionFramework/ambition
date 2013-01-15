/*
 * formvalidator.vala
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

public class FormValidatorTest {
	public static void add_tests() {
		Test.add_func("/ambition/form/validator/min_length", () => {
			assert( Ambition.Form.Validator.min_length( "abcd", 4 ) == true );
			assert( Ambition.Form.Validator.min_length( "abcd", 5 ) == false );
			assert( Ambition.Form.Validator.min_length( "a", 1 ) == true );
		});
		Test.add_func("/ambition/form/validator/max_length", () => {
			assert( Ambition.Form.Validator.max_length( "abcd", 4 ) == true );
			assert( Ambition.Form.Validator.max_length( "abcd", 5 ) == true );
			assert( Ambition.Form.Validator.max_length( "ab", 1 ) == false );
		});
		Test.add_func("/ambition/form/validator/is_numeric", () => {
			assert( Ambition.Form.Validator.is_numeric( "1234" ) == true );
			assert( Ambition.Form.Validator.is_numeric( "1234 " ) == false );
			assert( Ambition.Form.Validator.is_numeric( "1a234" ) == false );
			assert( Ambition.Form.Validator.is_numeric( "0.00123012031928" ) == true );
			assert( Ambition.Form.Validator.is_numeric( "-1" ) == true );
		});
	}
}