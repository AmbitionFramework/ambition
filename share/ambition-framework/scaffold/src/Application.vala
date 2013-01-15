using Ambition;

namespace %%namespace%% {
	/**
	 * Class containing bootstrap code for this application.
	 */
	public class Application : Ambition.Application {
		public override Ambition.Actions get_actions() {
			return new Actions();
		}

		public override void run( string[] args ) {
			base.run(args);
		}
	}
}
