/*
 * engine.vala
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

public class EngineTest {
	public static void add_tests() {
		Test.add_func("/ambition/engine/init", () => {
			var c = new Ambition.Engine.Base();
			assert( c != null );
		});
		Test.add_func("/ambition/engine/parse_request_body/non-form", () => {
			var state = get_state();

			string st_testdata = "This is test data.";
			InputStream is_testdata = new MemoryInputStream.from_data( st_testdata.data, null );

			var c = new Ambition.Engine.Base();
			c.hook_parse_request_body( state, st_testdata.length, new DataInputStream(is_testdata) );
			assert( (string) state.request.request_body == (string) st_testdata.data );
			assert( state.request.params.size == 1 );
			assert( state.request.params.has_key( st_testdata ) );
		});
		Test.add_func("/ambition/engine/parse_request_body/form", () => {
			var state = get_state();

			string st_testdata = "this=is%20form%20data&that=also";
			InputStream is_testdata = new MemoryInputStream.from_data( st_testdata.data, null );

			var c = new Ambition.Engine.Base();
			c.hook_parse_request_body( state, st_testdata.length, new DataInputStream(is_testdata) );
			assert( (string) state.request.request_body == (string) st_testdata.data );
			assert( state.request.params.size == 2 );
			assert( state.request.params["this"] == "is form data" );
			assert( state.request.params["that"] == "also" );
		});
		Test.add_func("/ambition/engine/parse_request_body/upload1", () => {
			var state = get_state();
			state.request.content_type = "multipart/form-data; boundary=AaB03x";

			string txt_data = """This a a test text file.""";
			string st_testdata = """--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x
Content-Disposition: form-data; name="tfile"; filename="file1.txt"
Content-Type: text/plain

%s
--AaB03x--
""".printf(txt_data).replace( "\n", "\r\n" );
			InputStream is_testdata = new MemoryInputStream.from_data( st_testdata.data, null );

			var c = new Ambition.Engine.Base();
			c.hook_parse_request_body( state, st_testdata.length, new DataInputStream(is_testdata) );
			assert( state.request.params.has_key("Larry") == true );
			assert( state.request.files.has_key("tfile") == true );
			assert( state.request.files["tfile"].filename == "file1.txt" );
			assert( state.request.files["tfile"].content_type == "text/plain" );
			assert( state.request.files["tfile"].file != null );

			uint8[] content_buffer = null;
			string etag_out = null;
			state.request.files["tfile"].file.load_contents( null, out content_buffer, out etag_out );
			assert( txt_data == (string) content_buffer );
		});
		Test.add_func("/ambition/engine/parse_request_body/upload2", () => {
			var state = get_state();
			state.request.content_type = "multipart/form-data; boundary=AaB03x";

			string txt_data = """This a a test text file.""";
			string gif_data = """GIF89a  ³     €   € €€   €€ € €€€€€ÀÀÀÿ   ÿ ÿÿ   ÿÿ ÿ ÿÿÿÿÿ!ù   ,       SÐI+rÅXkH8]ÙÆy < )-Êù©T¹Àrª–Éw³&ÑÃA€‚èË%5¨tÊ*E',ö)É^½Uèj¬½ZÉd3´œw©Tne^ÁD  ;""";
			string st_testdata = """--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x
Content-Disposition: form-data; name="tfile"; filename="file1.txt"
Content-Type: text/plain

%s
--AaB03x
Content-Disposition: form-data; name="gfile"; filename="file2.gif"
Content-Type: image/gif
Content-Transfer-Encoding: binary

%s
--AaB03x--
""".printf( txt_data, gif_data ).replace( "\n", "\r\n" );
			InputStream is_testdata = new MemoryInputStream.from_data( st_testdata.data, null );

			var c = new Ambition.Engine.Base();
			c.hook_parse_request_body( state, st_testdata.length, new DataInputStream(is_testdata) );
			assert( state.request.files.has_key("tfile") == true );
			assert( state.request.files["tfile"].filename == "file1.txt" );
			assert( state.request.files["tfile"].content_type == "text/plain" );
			assert( state.request.files["tfile"].file != null );

			uint8[] content_buffer = null;
			string etag_out = null;
			state.request.files["tfile"].file.load_contents( null, out content_buffer, out etag_out );
			assert( txt_data == (string) content_buffer );

			assert( state.request.files.has_key("gfile") == true );
			assert( state.request.files["gfile"].filename == "file2.gif" );
			assert( state.request.files["gfile"].content_type == "image/gif" );
			assert( state.request.files["gfile"].file != null );

			content_buffer = null;
			etag_out = null;
			state.request.files["gfile"].file.load_contents( null, out content_buffer, out etag_out );
			assert( gif_data == (string) content_buffer );
		});
	}

	private static Ambition.State get_state() {
		var state = new Ambition.State("test");
		state.request = new Ambition.Request();
		state.request.params = new Gee.HashMap<string,string>();
		state.response = new Ambition.Response();
		return state;
	}
}