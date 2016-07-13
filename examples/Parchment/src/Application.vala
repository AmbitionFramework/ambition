using Ambition;

namespace Parchment {
	/**
	 * Class containing bootstrap code for this application.
	 */
	public class Application : Ambition.Application {
		public override void create_routes() {
			add_route()
					.path("/")
					.method( HttpMethod.GET )
					.target( Controller.Entries.list );
			add_route()
					.path("/page/[page]")
					.method( HttpMethod.GET )
					.target( Controller.Entries.list );
			add_route()
					.path("/tag/[tag]")
					.method( HttpMethod.GET )
					.target( Controller.Entries.list_tag );
			add_route()
					.path("/tag/[tag]/page/[page]")
					.method( HttpMethod.GET )
					.target( Controller.Entries.list_tag );
			add_route()
					.path("/entries/[entry_id]/reply")
					.method( HttpMethod.POST )
					.target( Controller.Entries.reply );
			add_route()
					.path("/entries/[entry_id]")
					.method( HttpMethod.GET )
					.target( Controller.Entries.view );
			add_route()
					.path("/rss/atom.xml")
					.method( HttpMethod.GET )
					.target( Controller.Entries.atom );
			add_route()
					.path("/callback/reply")
					.method( HttpMethod.POST )
					.target( Controller.Callback.reply );
			add_route()
					.path("/admin/login")
					.method( HttpMethod.GET )
					.method( HttpMethod.POST )
					.target( Controller.Admin.login );
			add_route()
					.path("/admin/logout")
					.method( HttpMethod.GET )
					.target( Controller.Admin.logout );
			add_route()
					.path("/admin/entry")
					.method( HttpMethod.GET )
					.method( HttpMethod.POST )
					.target( Controller.Admin.check_user )
					.target( Controller.Admin.entry );
			add_route()
					.path("/admin/profile")
					.method( HttpMethod.GET )
					.method( HttpMethod.POST )
					.target( Controller.Admin.check_user )
					.target( Controller.Admin.profile );
			add_route()
					.path("/admin")
					.method( HttpMethod.GET )
					.method( HttpMethod.POST )
					.target( Controller.Admin.check_user )
					.target( Controller.Admin.dashboard );
		}

		/**
		 * Customize this method to perform actions when the application starts.
		 * @param args Command line arguments.
		 */
		public override bool init( string[] args ) {
			// Load Almanna entities and connect to the database.
			Almanna.Repo.from_loader( new Parchment.Model.DB.AlmannaLoader() );

			return true;
		}
	}
}
