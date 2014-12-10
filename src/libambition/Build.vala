/*
 * Build.vala
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

using Gee;
namespace Ambition {
	/**
	 * Build engine.
	 */
	public class Build : Object {
		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.Build");

		/**
		 * Target Ambition version.
		 */
		public string? target_version { get; set; }

		/**
		 * Read build config from path
		 */
		public bool parse_build_config( string file_path ) {
			File file;
			try {
				file = File.new_for_path(file_path);
				if ( !file.query_exists() ) {
					file = null;
				}
			} catch (IOError e) {
				logger.error( "Cannot open '%s'".printf(file_path), e );
			}

			if ( file == null ) {
				logger.error( "Build config '%s' is missing.".printf(file_path) );
				return false;
			}

			// Parse config file
			try {
				var input_stream = new DataInputStream( file.read() );
				string line;
				while ( ( line = input_stream.read_line(null) ) != null ) {
					parse_line(line);
				}
			} catch (Error e) {
				logger.error( "Error reading config \"%s\"".printf( file.get_path() ), e );
				return false;
			}

			return true;
		}

		internal void parse_line( string line ) {
			// Skip potential comments
			if ( line.has_prefix("#") || line.has_prefix("//") || line.length == 0 ) {
				return;
			}
			string key = line.substring( 0, line.index_of("=") ).chomp().chug();
			string value = line.substring( line.index_of("=") + 1 ).chomp().chug();
			string gfield = key.replace( "_", "-" );
			ParamSpec p = this.get_class().find_property(gfield);
			if ( p != null ) {
				Value v = Value( typeof(string) );
				v.set_string(value);
				this.set_property( gfield, v );
			}
		}
	}
}