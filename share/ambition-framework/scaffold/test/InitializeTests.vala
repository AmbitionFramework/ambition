/**
 * Test cases should be added to this method.
 */
void main ( string[] args ) {
	Test.init( ref args );

	ApplicationTest.add_tests();

	Test.run();
}