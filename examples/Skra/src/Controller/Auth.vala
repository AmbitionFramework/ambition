/*
 * Auth.vala
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

using Ambition;
using Skra;
using Skra.View;
namespace Skra.Controller {
	public class Auth : Object {

		public static Result login( State state ) {
			var login_form = new Form.Login();
			login_form.bind_state(state);

			if ( state.request.method == HttpMethod.POST && login_form.is_valid() ) {
				bool success = state.authorize( "ht", login_form.username, login_form.password );
				if (success) {
					return new CoreView.Redirect("/wiki");
				}
				login_form.add_form_error("Invalid username or password.");
			}
			return new Template.Auth.login(login_form);
		}

		public static Result logout( State state ) {
			state.logout();
			return new CoreView.Redirect("/wiki");
		}

	}
}
