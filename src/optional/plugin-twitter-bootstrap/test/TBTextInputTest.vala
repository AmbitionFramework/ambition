public class TBTextInputTest : Object {
	public static Ambition.Request get_request() {
		var r = new Ambition.Request();
		r.params = new Gee.HashMap<string,string>();
		return r;
	}

	public static void add_tests() {
		Test.add_func("/ambition/twitterbootstrap/tbtextinput", () => {
			var r = get_request();
			r.params.set( "first_name", "Foo" );
			assert( r.param("first_name") == "Foo" );

			var f = new FormSubclass();
			f.bind_request(r);

			string rendered = f.render_field( "first_name", new Ambition.Form.TBTextInput() );

			assert(
				rendered.contains(
					"""<label for="subclass_first_name" class="control-label">First Name</label>"""
				)
			);
			assert(
				rendered.contains(
					"""<input"""
				)
			);
			assert(
				rendered.contains(
					"""type="text""""
				)
			);
			assert(
				rendered.contains(
					"""id="subclass_first_name""""
				)
			);
			assert(
				rendered.contains(
					"""name="first_name""""
				)
			);
			assert(
				rendered.contains(
					"""value="Foo""""
				)
			);
			assert(
				rendered.contains(
					"""<div class="control-group""""
				)
			);
			assert(
				rendered.contains(
					"""class="help-block">Enter your first name</span>"""
				)
			);
		});
	}

}