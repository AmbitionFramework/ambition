/*
 * templatecompiler.vala
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

public class TemplateCompilerTest {
	public static void add_tests() {
		Test.add_func("/ambition/templatecompiler/init", () => {
			var s = new Ambition.TemplateCompiler();
			assert( s != null );
		});
		Test.add_func("/ambition/templatecompiler/template_state", () => {
			var state = Ambition.TemplateState() {
				template_name = "test",
				line_number = 0
			};
			assert( state.template_name == "test" );
			assert( state.line_number == 0 );
		});
		Test.add_func("/ambition/templatecompiler/parse_line/comment", () => {
			var s = new Ambition.TemplateCompiler();
			assert( s != null );
			var sb = new StringBuilder();
			string parameters = "";
			var state = Ambition.TemplateState() {
				template_name = "test",
				line_number = 1
			};
			string line = "@* foo";
			s.parse_line( sb, state, line, ref parameters );
			assert( sb.str == "" );
			assert( parameters == "" );
		});
		Test.add_func("/ambition/templatecompiler/parse_line/using", () => {
			var s = new Ambition.TemplateCompiler();
			assert( s != null );
			var sb = new StringBuilder();
			string parameters = "";
			var state = Ambition.TemplateState() {
				template_name = "test",
				line_number = 1
			};
			string line = "@using Gee";
			s.parse_line( sb, state, line, ref parameters );
			assert( sb.str == "using Gee; // L1\n" );
			assert( parameters == "" );
		});
		Test.add_func("/ambition/templatecompiler/parse_line/process/noparams", () => {
			var s = new Ambition.TemplateCompiler();
			assert( s != null );
			var sb = new StringBuilder();
			string parameters = "";
			var state = Ambition.TemplateState() {
				template_name = "test",
				line_number = 1
			};
			string line = """@process("Test.Template")""";
			s.parse_line( sb, state, line, ref parameters );
			assert( sb.str == "      b.append((new Template.Test.Template().to_string_with_state(state))); // L1\n" );
			assert( parameters == "" );
		});
	}
}
