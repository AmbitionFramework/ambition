/*
 * Document.vala
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

namespace Ambition.Couch {
	/**
	 * Base class for a Couch DB Database/Document type.
	 *
	 * To use this, create a subclass of Document, and override the
	 * database_name property to correspond to the existing database in CouchDB.
	 * For each JSON property to be stored, create a property corresponding to
	 * an allowed type in couchdb-glib, namely, string, int, bool, or double.
	 *
	 * You may use the subclass by calling load_from_id(id) or save() to load
	 * and save documents from the document store.
	 */
	public class Document : Object {
		private static Couchdb.Database database = null;
		private Couchdb.Document document = null;
		public string? id { get; set; }
		public string revision { get; protected set; }
		public bool in_storage { get { return ( revision != null ); } }
		public virtual string database_name { get; set; default = ""; }

		/**
		 * Retrieve an instance of Couchdb.Database, creates one if it is not
		 * already loaded.
		 */
		public Couchdb.Database get_database() {
			if ( database == null ) {
				database = new Couchdb.Database( Ambition.Couch.get_couch_session(), database_name );
			}
			return database;
		}

		/**
		 * Load a returned document from Couchdb into this class instance. A
		 * common use case is to create a constructor called .from_document(),
		 * and call the load() method from there.
		 * @param document An instance of Couchdb.Document
		 */
		public void load( Couchdb.Document document ) {
			this.document = document;
			id = document.get_id();
			revision = document.get_revision();

			foreach ( ParamSpec ps in this.get_class().list_properties() ) {
				if ( ps.name == "database-name" || ps.name == "id" || ps.name == "revision" || ps.name == "in-storage" ) {
					continue;
				}

				Value v = Value( ps.value_type );
				string? field = get_field_name( document, ps.name );
				if ( field == null ) {
					stderr.printf( "no field for %s", ps.name );
					continue;
				}

				if ( ps.value_type == typeof(string) ) {
					v.set_string( document.get_string_field(field) );
					this.set_property( ps.name, v );
				} else if ( ps.value_type == typeof(int) ) {
					v.set_int( document.get_int_field(field) );
					this.set_property( ps.name, v );
				} else if ( ps.value_type == typeof(double) ) {
					v.set_double( document.get_double_field(field) );
					this.set_property( ps.name, v );
				} else if ( ps.value_type == typeof(bool) ) {
					v.set_boolean( document.get_boolean_field(field) );
					this.set_property( ps.name, v );
				}
			}
		}

		/**
		 * Load a document from CouchDB using the unique ID into this class
		 * instance. A common use case is to create a constructor called
		 * .from_id(), and call the load() method from there.
		 * @param id A valid ID
		 */
		public bool load_from_id( string id ) throws Error {
			var document = get_database().get_document(id);
			if ( document != null ) {
				load(document);
				return true;
			}
			return false;
		}

		/**
		 * Save the current instance data to CouchDB. Will update an existing
		 * record if the ID matches. Will run the generate_id() method if the
		 * id is null.
		 */
		public bool save() throws Error {
			var database = get_database();
			Couchdb.Document document;

			if ( id == null ) {
				id = generate_id();
				document = new Couchdb.Document();
			} else {
				if ( this.document != null ) {
					document = this.document;
				} else {
					try {
						document = database.get_document(id);
					} catch (Error e) {
						document = new Couchdb.Document();
					}
				}
			}

			document.set_id(id);

			foreach ( ParamSpec ps in this.get_class().list_properties() ) {
				if ( ps.name == "database-name" || ps.name == "id" ) {
					continue;
				}

				Value v = Value( ps.value_type );
				this.get_property( ps.name, ref v );

				if ( ps.value_type == typeof(string) ) {
					document.set_string_field( ps.name.replace( "-", "_" ), v.get_string() );
				} else if ( ps.value_type == typeof(int) ) {
					document.set_int_field( ps.name.replace( "-", "_" ), v.get_int() );
				} else if ( ps.value_type == typeof(double) ) {
					document.set_double_field( ps.name.replace( "-", "_" ), v.get_double() );
				} else if ( ps.value_type == typeof(bool) ) {
					document.set_boolean_field( ps.name.replace( "-", "_" ), v.get_boolean() );
				}
			}

			return database.put_document(document);
		}

		/**
		 * Method to override to generate a new ID per your conventions. To
		 * automatically generate a random unique 40 character ID, return
		 * generate_random_sha_id().
		 */
		public virtual string generate_id() {
			Logger.error( "The document of type %s does not have a generate_id set.".printf( this.get_type().name() ) );
			return "";
		}

		/**
		 * Convenience method to generate a random SHA1 ID. This is calculated
		 * using a GLib-derived random number combined with the current time.
		 */
		public string generate_random_sha_id() {
			var dt = new DateTime.now_local();
			return Checksum.compute_for_string( ChecksumType.SHA1, "%ll%d%d".printf( dt.to_unix(), dt.get_microsecond(), Random.next_int() ) );
		}

		private string? get_field_name( Couchdb.Document document, string property_name ) {
			if ( document.has_field(property_name) ) {
				return property_name;
			}
			string undered = property_name.replace( "-", "_" );
			if ( document.has_field(undered) ) {
				return undered;
			}
			return null;
		}

	}
}