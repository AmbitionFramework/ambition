/*
 * TextCaptcha.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2013 Sensical, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

using Gee;
using Soup;
using Ambition;
namespace Ambition.Helper {
	public errordomain TextCaptchaError {
		COMMUNICATION_FAILURE,
		PARSE_FAILURE,
		MISSING_KEY,
		NO_QUESTION,
		UNKNOWN_ERROR
	}

	/**
	 * Helper to provide an interface to TextCaptcha [[http://textcaptcha.com]]
	 */
	public class TextCaptcha : Object {
		private const string base_url = "http://api.textcaptcha.com/%s";
		private MarkupParseContext context;
		private string current_node;
		private const MarkupParser parser = {
			element_open,
			element_end,
			element_text,
			null,
			null
		};

		/**
		 * Question to be posed to the user.
		 */
		public string question { get; private set; }
		/**
		 * List of MD5 hashes representing valid answers.
		 */
		public ArrayList<string> answers { get; private set; }

		/**
		 * Initalize TextCaptcha object with the API key found in the
		 * configuration.
		 */
		public TextCaptcha( State state ) throws TextCaptchaError {
			string api_key = Config.lookup("textcaptcha.key");
			if ( api_key == null ) {
				throw new TextCaptchaError.MISSING_KEY("Missing API key in textcaptcha.key");
			}
			parse_content( retrieve_captcha(api_key) );
		}

		internal TextCaptcha.test( string content ) throws TextCaptchaError {
			parse_content(content);
		}

		/**
		 * Initalize TextCaptcha object from serialized data generated from
		 * the serialize() method.
		 */
		public TextCaptcha.from_serialized( string serialized ) throws TextCaptchaError {
			var items = serialized.split("|||");
			if ( items.length > 0 ) {
				question = items[0];
				answers = new ArrayList<string>();
				foreach ( string answer in items[1:items.length] ) {
					answers.add(answer);
				}
			}
		}

		/**
		 * Serialize the current TextCaptcha instance as a string.
		 */
		public string serialize() {
			return string.joinv( "|||", { question, string.joinv( "|||", answers.to_array() ) } );;
		}

		/**
		 * Check a user-provided answer against the correct answers.
		 * @param user_answer User-provided answer
		 */
		public bool check_answer( string user_answer ) throws TextCaptchaError {
			if ( answers.size == 0 ) {
				throw new TextCaptchaError.UNKNOWN_ERROR("Missing answers");
			}
			string md5 = Checksum.compute_for_string( ChecksumType.MD5, user_answer.down().strip() );
			if ( md5 in answers ) {
				return true;
			}
			return false;
		}

		/**
		 * Static method to retrieve a question for TextCaptcha, and store the
		 * instance in the session for later answer-checking.
		 */
		public static string get_new_question( State state ) throws TextCaptchaError {
			var tc = new TextCaptcha(state);
			state.session.set_value( "text_captcha", tc.serialize() );
			return tc.question;
		}

		/**
		 * Static method to check an answer against a question in the session.
		 * Throws an error if a question doesn't exist.
		 * @param user_answer User-provided answer
		 */
		public static bool check_existing_answer( State state, string user_answer ) throws TextCaptchaError {
			string serialized = state.session.get_value("text_captcha");
			if ( serialized == null ) {
				throw new TextCaptchaError.NO_QUESTION("No question in session.");
			}
			var tc = new TextCaptcha.from_serialized(serialized);
			return tc.check_answer(user_answer);
		}

		private string retrieve_captcha( string api_key ) throws TextCaptchaError {
			var session = new Soup.SessionSync();
			var message = new Soup.Message( "GET", base_url.printf(api_key) );
			session.send_message(message);
			if ( message.status_code == 200 ) {
				return (string) message.response_body.data;
			} else {
				throw new TextCaptchaError.COMMUNICATION_FAILURE( "Received status %u".printf( message.status_code ) );
			}
		}

		private void parse_content( string content ) throws TextCaptchaError {
			question = null;
			answers = new ArrayList<string>();
			context = new MarkupParseContext(
				parser,
				0,
				this,
				destroy
			);
			try {
				context.parse( content, -1 );
			} catch (MarkupError me) {
				throw new TextCaptchaError.PARSE_FAILURE( me.message );
			}
		}

		private void element_open( MarkupParseContext context, string name,
                string[] attr_names, string[] attr_values ) throws MarkupError {
			current_node = name;
		}

		private void element_end( MarkupParseContext context, string name ) throws MarkupError {
			current_node = null;
		}

		private void element_text( MarkupParseContext context, string text, size_t text_len ) throws MarkupError {
			if ( current_node != null ) {
				switch (current_node) {
					case "question":
						this.question = text;
						break;
					case "answer":
						this.answers.add(text);
						break;
				}
			}
		}

		private void destroy() {}
	}
}