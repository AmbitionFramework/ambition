using Ambition;

namespace %%namespace%% {
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
			return true;
		}
	}
}
