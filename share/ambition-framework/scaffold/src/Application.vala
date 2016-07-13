using Ambition;

namespace %%namespace%% {
	/**
	 * Class containing bootstrap code for this application.
	 */
	public class Application : Ambition.Application {
		/**
		 * Configure the routes for this web application.
		 */
		public override void create_routes() {
			// Add a new route which responds to a GET request on /, and
			// sends it to the index method of Controller.Root.
			add_route()
					.method( HttpMethod.GET )
					.path("/")
					.target( Controller.Root.index );
		}

		/**
		 * Customize this method to perform actions when the application starts.
		 * @param args Command line arguments.
		 */
		public override bool init( string[] args ) {
			return true;
		}

		/**
		 * Optionally, provide an action when a request begins.
		 * @param state Current State
		 */
		 /*
		 public override void on_request_dispatch( State state ) {
		 }
		 */

		/**
		 * Optionally, provide an action when a request ends.
		 * @param state Current State
		 */
		 /*
		 public override void on_request_end( State state ) {
		 }
		 */
	}
}
