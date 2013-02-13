# CouchDB

## What is it for?

The CouchDB plugin provides <a href="http://couchdb.apache.org/">CouchDB</a> integration for Ambition. This includes a basic Document object, and the ability to use Documents as storage for sessions.

## Installation and Configuration

The CouchDB plugin can be installed using the usual Ambition plugin tool. The plugin will link with your application.

To change the configuration of the CouchDB plugin, edit your application's configuration file in the `config/` directory. The only configuration option is the URL of the Couch host.

    couch.url = http://localhost:5984

Optionally, for session storage, the name of the session database can be changed by altering _couch.session.database_ to the new name. The default is `session`.

## Using CouchDB

For each document type in CouchDB, it may be easiest to generate a Document object corresponding to the structure being stored in that document. For example, if we were storing a basic email, and didn't need a specific scheme for the document's ID:

    using Ambition.Couch;
    namespace wtf.Model.Couch {
        public class Mail : Document {
            public override string database_name { get; set; default = "mail"; }
            public string subject { get; set; default = ""; }
            public string from { get; set; default = ""; }
            public string to { get; set; default = ""; }
            public string body { get; set; default = ""; }

            public Mail() {}

            public Mail.from_id( string id ) {
                load_from_id(id);
            }

            public override string generate_id() {
                return generate_random_sha_id();
            }
        }
    }

The lifecycle of a document (create, load, save):

    var document = new Mail();
    document.subject = "Example";
    document.from = "Me <example@example.com>";
    document.to = "You <example2@example.com>";
    document.body = "Hi!";
    document.save();
    string id = document.id;

    var loaded = new Mail.from_id(id);
    loaded.body = "Hi again!";
    loaded.save();

## Using CouchDB for session storage

Create a database in CouchDB called "session", and configure the session storable.

    session.storable = StorableCouch
