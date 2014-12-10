public class ApplicationTest : Ambition.Testing.AbstractTestCase {
	public ApplicationTest() {
		base("Application");
		add_test( "init", init );
	}
	public void init() {
		var application = new %%namespace%%.Application();
		assert( application != null );
	}
}