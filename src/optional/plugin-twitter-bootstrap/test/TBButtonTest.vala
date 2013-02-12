public class TBButtonTest : Object {
	public static Ambition.Request get_request() {
		var r = new Ambition.Request();
		r.params = new Gee.HashMap<string,string>();
		return r;
	}

	public static void add_tests() {
		Test.add_func("/ambition/twitterbootstrap/tbbutton", () => {
			var f = new FormSubclass();

			string rendered = f.render_field( "submit", new Ambition.Form.TBButton() );

			assert(
				rendered.contains(
					"""class="btn""""
				)
			);
			assert(
				f.render_field( "submit", new Ambition.Form.TBButton.with_type( Ambition.Form.ButtonType.INFO ) ).contains(
					"""class="btn btn-info""""
				)
			);
		});
	}

}