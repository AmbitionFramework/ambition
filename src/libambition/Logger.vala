/*
 * Logger.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2014 Sensical, Inc.
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
	 * Deprecated logging functionality.
	 */
	namespace Logger {

		public const int DEBUG = 0;
		public const int INFO = 1;
		public const int WARN = 2;
		public const int ERROR = 3;
		
		[Deprecated( since = "0.2", replacement = "Log4Vala.Logger.debug" )]
		public static void debug( string message, ... ) {
			var l = va_list();
			Log4Vala.Logger.get_logger("ambition.logger").debug( message.vprintf(l) );
		}

		[Deprecated( since = "0.2", replacement = "Log4Vala.Logger.info" )]
		public static void info( string message, ... ) {
			var l = va_list();
			Log4Vala.Logger.get_logger("ambition.logger").info( message.vprintf(l) );
		}

		[Deprecated( since = "0.2", replacement = "Log4Vala.Logger.warn" )]
		public static void warn( string message, ... ) {
			var l = va_list();
			Log4Vala.Logger.get_logger("ambition.logger").warn( message.vprintf(l) );
		}

		[Deprecated( since = "0.2", replacement = "Log4Vala.Logger.error" )]
		public static void error( string message, ... ) {
			var l = va_list();
			Log4Vala.Logger.get_logger("ambition.logger").error( message.vprintf(l) );
		}

		[Deprecated( since = "0.2", replacement = "Log4Vala.Logger.log" )]
		private static async void write_log( string log_level, string message ) {
			Log4Vala.Logger.get_logger("ambition.logger").log(
				Log4Vala.Level.get_by_name(log_level),
				message
			);
		}
	}
}
