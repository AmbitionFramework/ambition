using Ambition.Form;
namespace Parchment.Form {

	/**
	 * Reply Form.
	 */
	public class Reply : FormDefinition {

		public int parent_comment_id { get; set; }
		public string content { get; set; }
		public string display_name { get; set; }
		public string email_address { get; set; }
		public string text_captcha { get; set; }

		[Description( nick = "Submit Comment" )]
		public string submit { get; set; }

	}
}
