using Ambition;

const string content = "<captcha>" +
"<question>If tomorrow is Saturday, what day is today?</question>" +
"<answer>f6f7fec07f372b7bd5eb196bbca0f3f4</answer>" +
"<answer>dfc47c8ef18b4689b982979d05cf4cc6</answer>" +
"</captcha>";

void main (string[] args) {
	Test.init( ref args );
	add_tests();
	Test.run();
}

static void add_tests() {
	Test.add_func("/ambition/textcaptcha/mock", () => {
		Ambition.Helper.TextCaptcha tc = null;
		try {
			tc = new Ambition.Helper.TextCaptcha.test(content);
		} catch (Error e) {
			stderr.printf( "Error: %s\n", e.message );
		}
		assert( tc != null );
		assert( tc.question != null );
		assert( tc.question == "If tomorrow is Saturday, what day is today?" );
		assert( tc.answers.size == 2 );
		assert( tc.check_answer("Friday") == true );
		assert( tc.check_answer("friday") == true );
		assert( tc.check_answer("fri") == true );
		assert( tc.check_answer("  fri ") == true );
		assert( tc.check_answer("thursday") == false );
	});
	Test.add_func("/ambition/textcaptcha/serialize", () => {
		var tc = new Ambition.Helper.TextCaptcha.test(content);
		string s = tc.serialize();
		tc = new Ambition.Helper.TextCaptcha.from_serialized(s);
		assert( tc.question == "If tomorrow is Saturday, what day is today?" );
		assert( tc.answers.size == 2 );
	});
}
