/*
 * Root.vala
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
using Skra.View;
using Skra.Model;
namespace Skra.Controller {
	public class Root : Object {

		public Result begin( State state ) {
			state.stash.set_string( "head_markdown", WikiNode.retrieve_latest("_component/head") );
			state.stash.set_string( "header_markdown", WikiNode.retrieve_latest("_component/header") );
			state.stash.set_string( "footer_markdown", WikiNode.retrieve_latest("_component/footer") );
			return new CoreView.None();
		}

		public Result index( State state ) {
			return new CoreView.Redirect("/wiki");
		}

		public Result session( State state ) {
			return new Template.Root.session();
		}

	}
}
