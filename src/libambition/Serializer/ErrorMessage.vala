/*
 * ErrorMessage.vala
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

namespace Ambition.Serializer {
	/**
	 * Represents a default error message and status code.
	 */
	public class ErrorMessage : Object {
		public enum ErrorType {
			MISSING_PARAMETER = 101,
			BAD_REQUEST = 400,
			UNAUTHENTICATED = 401,
			FORBIDDEN = 403,
			NOT_FOUND = 404,
			METHOD_NOT_ALLOWED = 405,
			UNSUPPORTED_MEDIA_TYPE = 415,
			ERROR = 500
		}

		public int code { get; set; }
		public string message { get; set; }

		public ErrorMessage( ErrorType error_type, string? message ) {
			this.code = (int) error_type;
			this.message = message;
		}
	}
}