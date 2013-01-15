public class ApplicationTest {
	public static void add_tests() {
		Test.add_func("/application/init", () => {
			var application = new %%namespace%%.Application();
			assert( application != null );
		});
	}
}