/*
 * Test.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
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

namespace Ambition.Engine {
	/**
	 * Test engine, for use by unit tests.
	 */
	public class Test : Base {

		public override string name {
			get { return "Test"; }
		}

		public override void execute() {
		}

		public State handle_request( Request request ) {
			State state = this.dispatcher.initialize_state("test");
			state.request = request;
			
			this._after_request(state);
			this.dispatcher.handle_request( state );
			this._after_render(state);

			state.response.headers["Date"] = new DateTime.now_utc().format("%a, %d %b %Y %H:%M:%S %Z");
			state.response.headers["Content-Type"] = state.response.content_type;
			state.response.headers["Content-Length"] = state.response.get_body_length().to_string();
			
			return state;
		}
	}
}
