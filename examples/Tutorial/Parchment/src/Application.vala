using Ambition;

namespace Parchment {
	/**
	 * Class containing bootstrap code for this application.
	 */
	public class Application : Ambition.Application {
		public override Ambition.Actions get_actions() {
			return new Actions();
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
