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
			int page = get_page(state);
			int pages = 1 + (int) ( (double) Entry.entry_count() / 10 - 0.1 );
			var entries = Entry.paged_entries(page).list();

			return new Template.Entries.list( entries, page, pages );
		}

		/**
		 * List entries page for Entries.
		 * @param state State object.
		 */
		public Result list_tag( State state ) {
			int page = get_page(state);
			var tag_pack = Entry.paged_tag_entries( state.request.get_capture("tag"), page );
			int pages = 1 + (int) ( (double) tag_pack.count / 10 - 0.1 );
			var entries = tag_pack.entries;

			return new Template.Entries.list( entries, page, pages );
		}

		private int get_page( State state ) {
			int page = 1;

			var page_string = state.request.get_capture("page");
			if ( page_string != null ) {
				page = int.parse(page_string);
			}
			return page;
		}

		/**
		 * View entry page for Entries.
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
			if ( Config.lookup_bool("allow_replies") == false ) {
				return null;
			}

			int entry_id = int.parse( state.request.get_capture("entry_id") );
			var entry = Entry.joined_search()
							.eq( "entry_id", entry_id )
							.single();

			var reply_form = new Form.Reply();
			reply_form.bind_state(state);

			if ( state.request.method == HttpMethod.POST && reply_form.is_valid() && entry != null ) {
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

			return new Template.Entries.reply(
				entry,
				reply_form.parent_comment_id,
				reply_form.reply_to,
				reply_form
			);
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
