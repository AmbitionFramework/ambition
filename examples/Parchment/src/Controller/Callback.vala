using Ambition;
using Almanna;
using Parchment.View;
using Parchment.Model.DB.Implementation;
namespace Parchment.Controller {

	/**
	 * Callback Controller.
	 */
	public class Callback : Object {

		/**
		 * Grab reply html.
		 * @param state State object.
		 */
		public Result reply( State state ) {
			var comment_id_string = state.request.params["comment_id"];
			var reply_to = "";
			Entry entry = null;
			int comment_id = ( comment_id_string == null ? 0 : int.parse(comment_id_string) );
			if ( comment_id > 0 ) {
				Comment comment = new Search<Comment>().lookup(comment_id);
				if ( comment != null ) {
					entry = Entry.joined_search()
								.eq( "entry_id", comment.entry_id )
								.single();
					reply_to = comment.display_name;
				} else {
					comment_id = 0;
				}
			}
			return new Template.Entries.reply( entry, comment_id, reply_to );
		}

	}
}
