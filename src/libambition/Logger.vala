/*
 * Logger.vala
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

namespace Ambition {
	/**
	 * Logging functionality.
	 */
	namespace Logger {

		public const int DEBUG = 0;
		public const int INFO = 1;
		public const int WARN = 2;
		public const int ERROR = 3;
		
		public class Unique {
			private string id;
			
			public Unique( string unique_id ) {
				id = unique_id;
			}
			
			public void debug( string message, ... ) {
				if ( App.log_level > DEBUG ) {
					return;
				}
				var l = va_list();
				write_log( "debug", message.vprintf(l) );
			}

			public void info( string message, ... ) {
				if ( App.log_level > INFO ) {
					return;
				}
				var l = va_list();
				write_log( "info", message.vprintf(l) );
			}

			public void warn( string message, ... ) {
				if ( App.log_level > WARN ) {
					return;
				}
				var l = va_list();
				write_log( "warn", message.vprintf(l) );
			}

			public void error( string message, ... ) {
				var l = va_list();
				write_log( "error", message.vprintf(l) );
			}

			private void write_log( string log_level, string message ) {
				Logger.write_log.begin(log_level, "<%s> ".printf(id) + message );
			}
			
		}
		
		public static void debug( string message, ... ) {
			if ( App.log_level > DEBUG ) {
				return;
			}
			var l = va_list();
			write_log.begin( "debug", message.vprintf(l) );
		}

		public static void info( string message, ... ) {
			if ( App.log_level > INFO ) {
				return;
			}
			var l = va_list();
			write_log.begin( "info", message.vprintf(l) );
		}

		public static void warn( string message, ... ) {
			if ( App.log_level > WARN ) {
				return;
			}
			var l = va_list();
			write_log.begin( "warn", message.vprintf(l) );
		}

		public static void error( string message, ... ) {
			var l = va_list();
			write_log.begin( "error", message.vprintf(l) );
		}

		private static async void write_log( string log_level, string message ) {
			var dt = new DateTime.now_local();
			stdout.printf(
				"[%s%06.3f] (%5s) %s\n",
				dt.format("%Y-%m-%d %H:%M:"),
				(float) dt.get_microsecond() / 1000000 + dt.get_second(),
				log_level,
				message
			);
		}
	}
}
