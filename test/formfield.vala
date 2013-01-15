/*
 * formfield.vala
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

public class FormFieldTest {
	public static Ambition.Request get_request() {
		var r = new Ambition.Request();
		r.params = new Gee.HashMap<string,string>();
		return r;
	}
	public static void add_tests() {
		Test.add_func("/ambition/form/field/error", () => {
			var r = get_request();
			r.params.set( "region", "invalid" );
			assert( r.param("region") == "invalid" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert( f != null );
			assert( f.region == "invalid" );
			assert( f.has_errors() == true );
			assert( f.is_valid() == false );
		});
		Test.add_func("/ambition/form/field/textinput/render", () => {
			var r = get_request();
			r.params.set( "first_name", "Foo" );
			assert( r.param("first_name") == "Foo" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert(
				f.render_field( "first_name", new Ambition.Form.TextInput() ).contains(
					"""<dl><dt><label for="subclass_first_name">First Name</label>"""
				)
			);
			assert(
				f.render_field( "first_name", new Ambition.Form.TextInput() ).contains(
					"""<input"""
				)
			);
			assert(
				f.render_field( "first_name", new Ambition.Form.TextInput() ).contains(
					"""type="text""""
				)
			);
			assert(
				f.render_field( "first_name", new Ambition.Form.TextInput() ).contains(
					"""id="subclass_first_name""""
				)
			);
			assert(
				f.render_field( "first_name", new Ambition.Form.TextInput() ).contains(
					"""name="first_name""""
				)
			);
			assert(
				f.render_field( "first_name", new Ambition.Form.TextInput() ).contains(
					"""value="Foo""""
				)
			);
			assert(
				f.render_field( "first_name", new Ambition.Form.TextInput() ).contains(
					"""<div """
				)
			);
			assert(
				f.render_field( "first_name", new Ambition.Form.TextInput() ).contains(
					"""class="input_hint""""
				)
			);
			assert(
				f.render_field( "first_name", new Ambition.Form.TextInput() ).contains(
					""">Enter your first name</div></dd></dl>"""
				)
			);

		});
		Test.add_func("/ambition/form/field/passwordinput/render", () => {
			var r = get_request();
			r.params.set( "password", "passwerd" );
			assert( r.param("password") == "passwerd" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert(
				f.render_field( "password", new Ambition.Form.PasswordInput() ).contains(
					"""<dl><dt><label for="subclass_password">password</label>"""
				)
			);
			assert(
				f.render_field( "password", new Ambition.Form.PasswordInput() ).contains(
					"""<input"""
				)
			);
			assert(
				f.render_field( "password", new Ambition.Form.PasswordInput() ).contains(
					"""type="password""""
				)
			);
			assert(
				f.render_field( "password", new Ambition.Form.PasswordInput() ).contains(
					"""value="passwerd""""
				)
			);

		});
		Test.add_func("/ambition/form/field/textinput/render/error", () => {
			var r = get_request();
			r.params.set( "region", "Foo" );
			assert( r.param("region") == "Foo" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert(
				f.render_field( "region", new Ambition.Form.TextInput() ).contains(
					"Region must be two characters"
				)
			);
		});
		Test.add_func("/ambition/form/field/hiddeninput/render", () => {
			var r = get_request();
			r.params.set( "identifier", "Foo" );
			assert( r.param("identifier") == "Foo" );

			var f = new FormSubclass();
			f.bind_request(r);

			assert(
				f.render_field( "identifier", new Ambition.Form.HiddenInput() ).contains(
					"""<input"""
				)
			);
			assert(
				f.render_field( "identifier", new Ambition.Form.HiddenInput() ).contains(
					"""type="hidden""""
				)
			);
			assert(
				f.render_field( "identifier", new Ambition.Form.HiddenInput() ).contains(
					"""id="subclass_identifier""""
				)
			);
			assert(
				f.render_field( "identifier", new Ambition.Form.HiddenInput() ).contains(
					"""name="identifier""""
				)
			);
			assert(
				f.render_field( "identifier", new Ambition.Form.HiddenInput() ).contains(
					"""value="Foo""""
				)
			);
		});
		Test.add_func("/ambition/form/field/radiogroupinput/render", () => {
			var r = get_request();
			r.params.set( "multiselect", "Foo,Bar" );
			assert( r.param("multiselect") == "Foo,Bar" );

			var f = new FormSubclass();
			f.bind_request(r);

			string[] values = { "foo", "bar", "baz" };
			string[] labels = { "Foo", "Bar", "Baz" } ;
			var renderer = new Ambition.Form.RadioGroupInput.with_options( values, labels );
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""<input"""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""type="radio""""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""name="multiselect""""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""value="foo""""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""value="bar""""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""value="baz""""
				)
			);
		});
		Test.add_func("/ambition/form/field/checkboxgroupinput/render", () => {
			var r = get_request();
			r.params.set( "multiselect", "Foo,Bar" );
			assert( r.param("multiselect") == "Foo,Bar" );

			var f = new FormSubclass();
			f.bind_request(r);

			string[] values = { "foo", "bar", "baz" };
			string[] labels = { "Foo", "Bar", "Baz" } ;
			var renderer = new Ambition.Form.CheckboxGroupInput.with_options( values, labels );
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""<input"""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""type="checkbox""""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""name="multiselect""""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""value="foo""""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""value="bar""""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""value="baz""""
				)
			);
		});
		Test.add_func("/ambition/form/field/selectgroupinput/render", () => {
			var r = get_request();
			r.params.set( "multiselect", "Foo,Bar" );
			assert( r.param("multiselect") == "Foo,Bar" );

			var f = new FormSubclass();
			f.bind_request(r);

			string[] values = { "foo", "bar", "baz" };
			string[] labels = { "Foo", "Bar", "Baz" } ;
			var renderer = new Ambition.Form.SelectGroupInput.with_options( values, labels );
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""<select"""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""name="multiselect""""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""<option value="foo""""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""<option value="bar""""
				)
			);
			assert(
				f.render_field( "multiselect", renderer ).contains(
					"""<option value="baz""""
				)
			);
		});
		Test.add_func("/ambition/form/field/button/render", () => {
			var r = get_request();
			r.params.set( "submit", "Do it!" );
			assert( r.param("submit") == "Do it!" );

			var f = new FormSubclass();
			f.bind_request(r);

			var renderer = new Ambition.Form.Button();
			assert(
				f.render_field( "submit", renderer ).contains(
					"""<button"""
				)
			);
			assert(
				f.render_field( "submit", renderer ).contains(
					"""type="button""""
				)
			);
			assert(
				f.render_field( "submit", renderer ).contains(
					"""name="submit""""
				)
			);
			assert(
				f.render_field( "submit", renderer ).contains(
					""">Do it!</button>"""
				)
			);
		});
		Test.add_func("/ambition/form/field/submitbutton/render", () => {
			var r = get_request();
			r.params.set( "submit", "Do it!" );
			assert( r.param("submit") == "Do it!" );

			var f = new FormSubclass();
			f.bind_request(r);

			var renderer = new Ambition.Form.SubmitButton();
			assert(
				f.render_field( "submit", renderer ).contains(
					"""<button"""
				)
			);
			assert(
				f.render_field( "submit", renderer ).contains(
					"""type="submit""""
				)
			);
			assert(
				f.render_field( "submit", renderer ).contains(
					"""name="submit""""
				)
			);
			assert(
				f.render_field( "submit", renderer ).contains(
					""">Do it!</button>"""
				)
			);
		});
		Test.add_func("/ambition/form/field/resetbutton/render", () => {
			var r = get_request();
			r.params.set( "submit", "Do it!" );
			assert( r.param("submit") == "Do it!" );

			var f = new FormSubclass();
			f.bind_request(r);

			var renderer = new Ambition.Form.ResetButton();
			assert(
				f.render_field( "submit", renderer ).contains(
					"""<button"""
				)
			);
			assert(
				f.render_field( "submit", renderer ).contains(
					"""type="reset""""
				)
			);
			assert(
				f.render_field( "submit", renderer ).contains(
					"""name="submit""""
				)
			);
			assert(
				f.render_field( "submit", renderer ).contains(
					""">Do it!</button>"""
				)
			);
		});
	}
}

