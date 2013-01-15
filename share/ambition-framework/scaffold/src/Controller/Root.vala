using Ambition;
using %%namespace%%.View;
namespace %%namespace%%.Controller {
	public class Root : Object {

		public Result index( State state ) {
			return new Template.Root.index( "%%namespace%%", state.request.headers );
		}

	}
}
