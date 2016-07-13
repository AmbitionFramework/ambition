/*
 * WikiMarkdown.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2016 Sensical, Inc.
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

using Ambition;
namespace Skra.Model {
	/**
	 * Interface to the markdown library, with customizations for Skra.
	 */
	public class WikiMarkdown : Object {
		private static Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Skra.Model.WikiMarkdown");

		/**
		 * Given content in a string, parse into HTML and return
		 * @param markdown_content Source content
		 * @return string
		 */
		public static string process( string markdown_content ) {

			// Process markdown content
			string result = Ambition.Helper.Markdown.process(markdown_content);

			// Match [[foo]]
			try {
				Regex link = new Regex("\\[\\[([^\\[]+)\\]\\]");
				result = link.replace_eval( result, -1, 0, 0, linkify );
			} catch (RegexError e) {
				logger.error( "Bad regex on [[link]]: %s".printf( e.message ) );
			}

			/*
			 * TODO: This is a good opportunity to develop some kind of macro or
			 * plugin system.
			 */
			// Match {include FooBar}
			try {
				Regex include = new Regex( "\\{include ([^\\}]+)\\}", RegexCompileFlags.CASELESS );
				result = include.replace_eval( result, -1, 0, 0, includify );
			} catch (RegexError e) {
				logger.error( "Bad regex on {include}: %s".printf( e.message ) );
			}

			return result;
		}

		/**
		 * Process links within markdown content, as a part of replace_eval.
		 * @param match_info MatchInfo instance from the link regex
		 * @param result     StringBuilder instance to append to
		 */
		private static bool linkify( MatchInfo match_info, StringBuilder result ) {
			string[] content = match_info.fetch(1).split("|");
			string link = content[0];
			string title = content[0];
			if ( content.length > 1 && content[1] != null ) {
				title = content[1];
			}
			if ( link.substring( 0, 1 ) != "/" && !link.contains("://") ) {
				link = "/wiki/" + link;
			}
			result.append( "<a href=\"%s\">%s</a>".printf( link, title ) );
			return false;
		}

		/**
		 * Process includes within markdown content, as a part of replace_eval.
		 * @param match_info MatchInfo instance from the include regex
		 * @param result     StringBuilder instance to append to
		 */
		public static bool includify( MatchInfo match_info, StringBuilder result ) {
			string node = match_info.fetch(1);
			string content = process( WikiNode.retrieve_latest(node) );
			if ( content != null ) {
				result.append(content);
			} else {
				result.append( "<div class=\"errormessage\">Invalid or missing node in include \"%s\".</div>".printf(node) );
			}
			return false;
		}
	}
}
