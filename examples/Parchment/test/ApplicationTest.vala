public class ApplicationTest {
	public static void add_tests() {
		Test.add_func("/application/init", () => {
			var application = new Parchment.Application();
			assert( application != null );
		});
	}
}
