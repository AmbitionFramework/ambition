using Ambition;
using Parchment.View;
using Parchment.Model.DB.Implementation;
using Gee;
namespace Parchment.Controller {

	/**
	 * Entries Controller.
	 */
	public class Entries : Object {

		/**
		 * List entries page for Entries.
		 * @param state State object.
		 */
		public Result list( State state ) {
			int page = 1;
			int pages = 1 + (int) ( (double) Entry.entry_count() / 10 - 0.1 );

			var page_string = state.request.get_capture("page");
			if ( page_string != null ) {
				page = int.parse(page_string);
			}

			var entries = Entry.paged_entries(page).list();

			return new Template.Entries.list( entries, page, pages );
		}

		/**
		 * List entries page for Entries.
		 * @param state State object.
		 */
		public Result view( State state ) {
			int entry_id = int.parse( state.request.get_capture("entry_id") );
			var entry = Entry.joined_search()
							.eq( "entry_id", entry_id )
							.single();
			return new Template.Entries.view(entry);
		}

		/**
		 * Post a reply to a comment in an entry.
		 * @param state State object.
		 */
		public Result reply( State state ) {
			int entry_id = int.parse( state.request.get_capture("entry_id") );
			var entry = Entry.joined_search()
							.eq( "entry_id", entry_id )
							.single();

			var reply_form = new Form.Reply();
			reply_form.bind_state(state);

			if ( state.request.method == HttpMethod.POST && reply_form.is_valid() && entry != null ) {
				if ( ! state.has_user ) {
					if ( reply_form.text_captcha != null ) {
						bool success = Helper.TextCaptcha.check_existing_answer(
							state,
							reply_form.text_captcha
						);
						if (!success) {
							return new CoreView.Redirect("/");
						}
					} else {
						return new CoreView.Redirect("/");
					}
				}
				var comment = new Comment();
				comment.bind_data_from(reply_form);
				comment.entry_id = entry.entry_id;
				comment.ip_address = state.request.ip;
				comment.save();
				if ( comment.parent_comment_id == 0 ) {
					comment.parent_comment_id = comment.comment_id;
					comment.save();
				}
				return new CoreView.Redirect( "/entries/" + entry_id.to_string() );
			}

			return new CoreView.Redirect("/");
		}

		/**
		 * Render an Atom-based RSS feed.
		 * @param state State object.
		 */
		public Result atom( State state ) {
			var entries = Entry.paged_entries(1).list();
			state.response.content_type = "application/atom+xml";
			return new Template.Entries.atom(entries);
		}

	}
}
