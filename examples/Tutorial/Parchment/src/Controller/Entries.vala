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
			var page_string = state.request.get_capture("page");
			if ( page_string != null ) {
				page = int.parse(page_string);
			}

			var search = new Almanna.Search<Entry>()          // Create a Search
							.relationship("publisher");       // Use publisher relationship

			int pages = 1 + (int) ( (double) search.count() / 10 - 0.1 );
			var entries = search
							.order_by( "date_created", true ) // Order by, descending
							.rows(10)                         // Show 10 entries per page
							.page(page)                       // Use page from page var
							.list();                          // Retrieve as an ArrayList

			return new Template.Entries.list( entries, page, pages );
		}

		/**
		 * List entries page for Entries.
		 * @param state State object.
		 */
		public Result view( State state ) {
			int entry_id = int.parse( state.request.get_capture("entry_id") );
			var entry = new Almanna.Search<Entry>()
							.eq( "entry_id", entry_id )
							.relationship("publisher")
							.single();
			return new Template.Entries.view(entry);
		}

	}
}
