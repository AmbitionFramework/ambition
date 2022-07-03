using Ambition;
using Ambition.Testing;

public class ApplicationTest : Ambition.Testing.AbstractTestCase {
	public ApplicationTest() {
		base("Application");
		add_test( "init", init );
		add_test( "happy_example_page", happy_example_page );
	}

	public override void set_up() {
		// Quiet down the logs except for errors for the duration of this test.
		Ambition.App.log_level = Ambition.Logger.ERROR;
		Log4Vala.Config.get_config().root_level = Log4Vala.Level.ERROR;
	}

	/**
	 * Verify that the core application object loads successfully without
	 * throwing an Error.
	 */
	public void init() {
		var application = new %%namespace%%.Application();
		assert( application != null );
	}

	/**
	 * Test the example page provided with the scaffolded application. Once this
	 * page disappears, this test will fail -- don't forget to remove!
	 */
	public void happy_example_page() {
		// Create a mock Request object with a GET request to /
		var request = Helper.get_mock_request( HttpMethod.GET, "/" );

		// Dispatch the request using this application's router
		var result = Helper.mock_dispatch_with_request( new %%namespace%%.Application(), request );

		// With the given response, check our assumptions:
		// - the HTTP status is 200
		assert( result.status_is(200) );

		// - the content type is text/html
		assert( result.content_type_is("text/html") );

		// - the content contains a title with the application name
		assert( result.content_like("<title>%%namespace%% Test</title>") );

		// - the content contains our generic heading with the application name
		assert( result.content_like("<h1>Welcome to %%namespace%%</h1>") );

		// - the content contains the default Ambition powered by header
		assert( result.header_is( "X-Powered-By", "Ambition" ) );
	}
}
