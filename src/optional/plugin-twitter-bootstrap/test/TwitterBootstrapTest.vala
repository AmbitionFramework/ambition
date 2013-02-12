void main (string[] args) {
	Test.init( ref args );
	TBTextInputTest.add_tests();
	TBButtonTest.add_tests();
	Test.run();
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
