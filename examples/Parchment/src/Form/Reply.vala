using Ambition;
using Ambition.Form;
using Parchment.Model.DB.Implementation;
namespace Parchment.Form {

	/**
	 * Reply Form.
	 */
	public class Reply : FormDefinition {

		public int parent_comment_id { get; set; default = 0; }
		public string reply_to { get; set; default = ""; }
		public string content { get; set; }
		public string display_name { get; set; }
		public string email_address { get; set; }
		public string text_captcha { get; set; }

		[Description( nick = "Submit Comment" )]
		public string submit { get; set; }

		private State state = null;

		/**
		 * Override bind_state to keep the state object around.
		 * @param state State object
		 */
		public override void bind_state( State state ) {
			this.state = state;
			base.bind_state(state);
		}

		public override bool validate_form() {
			if ( state != null && ! state.has_user && Config.lookup("textcaptcha.key") != null ) {
				if ( this.text_captcha != null ) {
					bool success = Helper.TextCaptcha.check_existing_answer(
						state,
						this.text_captcha
					);
					if (success) {
						return true;
					}
				}
				this.add_field_error( "text_captcha", "Invalid response." );
			} else if ( state.has_user ) {
				display_name = ( (Publisher) state.user.get_object() ).display_name;
				return true;
			} else if ( Config.lookup("textcaptcha.key") == null ) {
				return true;
			}
			return false;
		}
	}
}
