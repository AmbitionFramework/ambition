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

public class FormSubclass : Ambition.Form.FormDefinition {
	private string _region;

	public string identifier { get; set; }

	[Description( nick="First Name", blurb="Enter your first name" )]
	public string first_name { get; set; }

	public string last_name { get; set; }
	public string city { get; set; }

	[Description( nick="Region", blurb="Enter your region (2 characters)" )]
	public string region {
		get {
			return _region;
		}
		set {
			if ( !Ambition.Form.Validator.max_length( value, 2 ) ) {
				this.add_field_error( "region", "Region must be two characters" );
			}
			_region = value;
		}
	}
	public string zip { get; set; }
	public bool has_registered { get; set; }
	public int age { get; set; }
	public char gender { get; set; }
	public double balance { get; set; }
	public uint unsupported { get; set; }
	public string[] multiselect { get; set; }

	public string password { get; set; }

	[Description( nick = "Do it!" )]
	public string submit { get; set; default = "Do it!"; }

	public FormSubclass() {
		this.form_name = "subclass";
	}
}
