/**
 * Test cases should be added to this method.
 */
void main ( string[] args ) {
	Test.init( ref args );

	var test_root = TestSuite.get_root();
	test_root.add_suite( new ApplicationTest().get_suite() );

	Test.run();
}