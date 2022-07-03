/*
 * Stash.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
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
	 * Stash or cache of data that lasts for the life of a request. This is
	 * helpful when preparing values during a "begin" or while transferring data
	 * between methods.
	 */
	public class Stash : HashMap<string,Value?> {
		/**
		 * Get an Object.
		 * @param key Key
		 */
		public Object? get_object( string key ) {
			var v = this.get(key);
			if ( v != null ) {
				return v.get_object();
			}
			return null;
		}

		/**
		 * Put an Object in the cache.
		 * @param key Key
		 * @param v Object
		 */
		public void set_object( string key, Object v ) {
			var val = Value( v.get_type() );
			val.set_object(v);
			this.set( key, val );
		}

		/**
		 * Get a string.
		 * @param key Key
		 */
		public string? get_string( string key ) {
			var v = this.get(key);
			if ( v != null ) {
				return v.get_string();
			}
			return null;
		}

		/**
		 * Put a string in the cache.
		 * @param key Key
		 * @param v string
		 */
		public void set_string( string key, string v ) {
			var val = Value( typeof(string) );
			val.set_string(v);
			this.set( key, val );
		}

		/**
		 * Get a boolean.
		 * @param key Key
		 */
		public bool? get_boolean( string key ) {
			var v = this.get(key);
			if ( v != null ) {
				return v.get_boolean();
			}
			return null;
		}

		/**
		 * Put a boolean in the cache.
		 * @param key Key
		 * @param v boolean
		 */
		public void set_boolean( string key, bool v ) {
			var val = Value( typeof(bool) );
			val.set_boolean(v);
			this.set( key, val );
		}

		/**
		 * Get a float.
		 * @param key Key
		 */
		public float? get_float( string key ) {
			var v = this.get(key);
			if ( v != null ) {
				return v.get_float();
			}
			return null;
		}

		/**
		 * Put a float in the cache.
		 * @param key Key
		 * @param v float
		 */
		public void set_float( string key, float v ) {
			var val = Value( typeof(float) );
			val.set_float(v);
			this.set( key, val );
		}

		/**
		 * Get an int64.
		 * @param key Key
		 */
		public int64? get_int64( string key ) {
			var v = this.get(key);
			if ( v != null ) {
				return v.get_int64();
			}
			return null;
		}

		/**
		 * Put an int64 in the cache.
		 * @param key Key
		 * @param v int64
		 */
		public void set_int64( string key, int64 v ) {
			var val = Value( typeof(int64) );
			val.set_int64(v);
			this.set( key, val );
		}

		/**
		 * Get an int.
		 * @param key Key
		 */
		public int? get_int( string key ) {
			var v = this.get(key);
			if ( v != null ) {
				return v.get_int();
			}
			return null;
		}

		/**
		 * Put an int in the cache.
		 * @param key Key
		 * @param v int
		 */
		public void set_int( string key, int v ) {
			var val = Value( typeof(int) );
			val.set_int(v);
			this.set( key, val );
		}

		/**
		 * Get a double.
		 * @param key Key
		 */
		public double? get_double( string key ) {
			var v = this.get(key);
			if ( v != null ) {
				return v.get_double();
			}
			return null;
		}

		/**
		 * Put a double in the cache.
		 * @param key Key
		 * @param v double
		 */
		public void set_double( string key, double v ) {
			var val = Value( typeof(double) );
			val.set_double(v);
			this.set( key, val );
		}
	}
}
