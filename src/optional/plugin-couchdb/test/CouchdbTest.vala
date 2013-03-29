
void main (string[] args) {
	Test.init( ref args );
	add_tests();
	Test.run();
}

public static void add_tests() {
	Test.add_func("/ambition/plugin/couchdb", () => {
		var plugin = new Ambition.PluginSupport.CouchPlugin();
		assert( plugin != null );
		plugin.register_plugin();
	});
	if ( allow_live_tests() ) {
		Test.add_func("/ambition/plugin/couchdb/live/get_couch_session", () => {
			Ambition.Config.set_value( "couch.url", "http://localhost:5984" );
			var session = Ambition.Couch.get_couch_session();
			assert( session != null );
		});
		Test.add_func("/ambition/plugin/couchdb/live/create_test_database", () => {
			Ambition.Config.set_value( "couch.url", "http://localhost:5984" );
			var session = Ambition.Couch.get_couch_session();
			try {
				session.delete_database("ambition_plugin_couchdb_test");
			} catch (Error e) {
				// We don't actually care if this fails.
			}
			try {
				assert( session.create_database("ambition_plugin_couchdb_test") == true );
				assert( session.delete_database("ambition_plugin_couchdb_test") == true );
			} catch (Error e) {
				assert_not_reached();
			}
		});
		Test.add_func("/ambition/plugin/couchdb/live/document_subclass", () => {
			create_test_database();
			var document = new ExampleCouchDocument();
			assert( document != null );
			drop_test_database();
		});
		Test.add_func("/ambition/plugin/couchdb/live/document_subclass/save", () => {
			create_test_database();
			var document = new ExampleCouchDocument();
			assert( document != null );
			document.some_int_value = 12;
			document.some_string_value = "twelve";
			document.some_double_value = 12.04;
			document.some_bool_value = true;
			try {
				assert( document.save() == true );
			} catch (Error e) {
				assert_not_reached();
			}
			drop_test_database();
		});
		Test.add_func("/ambition/plugin/couchdb/live/document_subclass/load_from_id", () => {
			create_test_database();
			var document = new ExampleCouchDocument();
			assert( document != null );
			document.some_int_value = 12;
			document.some_string_value = "twelve";
			document.some_double_value = 12.04;
			document.some_bool_value = true;
			try {
				assert( document.save() == true );
			} catch (Error e) {
				assert_not_reached();
			}
			string id = document.id;
			document = null;
			document = new ExampleCouchDocument();
			assert( document != null );
			try {
				assert( document.load_from_id(id) == true );
			} catch (Error e) {
				assert_not_reached();
			}
			assert( document.id == id );
			assert( document.some_int_value == 12 );
			assert( document.some_string_value == "twelve" );
			assert( document.some_double_value == 12.04 );
			assert( document.some_bool_value == true );
			drop_test_database();
		});
		Test.add_func("/ambition/plugin/couchdb/live/document_subclass/save_existing", () => {
			create_test_database();
			var document = new ExampleCouchDocument();
			assert( document != null );
			document.some_int_value = 12;
			document.some_string_value = "twelve";
			try {
				assert( document.save() == true );
			} catch (Error e) {
				assert_not_reached();
			}
			string id = document.id;
			document = null;
			document = new ExampleCouchDocument();
			assert( document != null );
			try {
				assert( document.load_from_id(id) == true );
			} catch (Error e) {
				assert_not_reached();
			}
			assert( document.id == id );
			document.some_int_value = 13;
			try {
				assert( document.save() == true );
			} catch (Error e) {
				assert_not_reached();
			}
			document = null;
			document = new ExampleCouchDocument();
			assert( document != null );
			try {
				assert( document.load_from_id(id) == true );
			} catch (Error e) {
				assert_not_reached();
			}
			assert( document.some_int_value == 13 );
			drop_test_database();
		});
		Test.add_func("/ambition/plugin/couchdb/live/document_subclass/list", () => {
			create_test_database();
			for( var i = 1; i < 5; i++ ) {
				var document = new ExampleCouchDocument();
				assert( document != null );
				document.some_int_value = i;
				document.some_string_value = "twelve";
				document.some_double_value = i + 0.04;
				document.some_bool_value = true;
				try {
					assert( document.save() == true );
				} catch (Error e) {
					assert_not_reached();
				}
			}
			var list = ( new ExampleCouchDocument() ).list();
			assert( list != null );
			assert( list.size == 4 );
			assert( ( ( ExampleCouchDocument) list[0] ).some_int_value == 1 );
			drop_test_database();
		});
	} else {
		stdout.printf( "%s\n", "Skipping live tests. Enable with COUCH_LIVE_TESTS=1." );
	}
}

public static bool allow_live_tests() {
	string? live = Environment.get_variable("COUCH_LIVE_TESTS");
	return ( live != null && live == "1" );
}

public static void create_test_database() {
	Ambition.Config.set_value( "couch.url", "http://localhost:5984" );
	var session = Ambition.Couch.get_couch_session();
	try {
		assert( session.create_database("ambition_plugin_couchdb_test") == true );
	} catch (Error e) {}
}

public static void drop_test_database() {
	var session = Ambition.Couch.get_couch_session();
	try {
		session.delete_database("ambition_plugin_couchdb_test");
	} catch (Error e) {}
}

public class ExampleCouchDocument : Ambition.Couch.Document {
	public override string database_name { get; set; default = "ambition_plugin_couchdb_test"; }

	public int some_int_value { get; set; }
	public string some_string_value { get; set; }
	public bool some_bool_value { get; set; }
	public double some_double_value { get; set; }

	public override string generate_id() {
		return generate_random_sha_id();
	}
}
