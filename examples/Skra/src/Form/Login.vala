/*
 * Login.vala
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

using Ambition;
using Ambition.Form;
namespace Skra.Form {
	public class Login : FormDefinition {

		[Description( nick = "Username" )]
		public string username { get; set; }

		[Description( nick = "Password" )]
		public string password { get; set; }

		[Description( nick = "Login" )]
		public string login_button { get; set; default = "Login"; }
	}
}
