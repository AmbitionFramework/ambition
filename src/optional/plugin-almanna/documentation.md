# Almanna

## What is it for?

The Almanna plugin provides integration with the Almanna ORM to an Ambition application. This includes loading of Almanna entities, and the ability to use Almanna entities as a source of authorization or storage for sessions.

## Installation and Configuration

The Almanna plugin can be installed using the usual Ambition plugin tool. The plugin will link with your application.

To change the configuration of the Almanna plugin, edit your application's configuration file in the `config/` directory.

_almanna.provider_ - Required. The libgda database provider, and should match the beginning of the connection string. Examples include PostgreSQL, SQLite.

_almanna.connection\_string_ - Required. The libgda connection string, as required by the database provider. For example, `PostgreSQL://HOST=127.0.0.1;DB_NAME=example`.

_almanna.username_ - The username for the database being connected to.

_almanna.password_ - The password for the database being connected to.

_almanna.log\_level_ - Log level for Almanna output, corresponding to the values in Almanna.LogLevel.

_almanna.connections_ - Number of database connections to create.

## Loading Almanna entities

Generate the Almanna entities for your schema, and store them within the Model directory of your application.

    perl /path/to/almanna/generate-schema.pl --dsn "dbi:SQLite:example.db" --output src/Model/DB --namespace ExampleApp.Model.DB

Add the generated files to your `src/CMakeLists.txt` file.

Edit `src/Application.vala` to add an `init()` method, or add to your existing `init()` method.

    public override bool init( string[] args ) {
        Almanna.Repo.from_loader( new ExampleApp.Model.DB.AlmannaLoader() );
        return true;
    }

## Using Almanna for authorization

Assuming there is already an entity for authentication information, you will only need to tell the plugin about that entity. Within your application configuration, edit an existing authorization configuration, or create a new one. In this example, the entity is ExampleApp.Model.DB.Auth, containing a 'auth_id' field generated by the database, a 'username' field and a 'password_hash' field with a simple SHA1 hash of the user's password.

    authorization.default.type = Almanna
    authorization.default.entity_type = ExampleAppModelDBAuth
    authorization.default.id_field = auth_id
    authorization.default.username_field = username
    authorization.default.password_field = password_hash
    authorization.default.password_type = SHA1

You can then make an authorization call against the authorizer named "default", and it will use the information in the database.

    if ( state.authorize( "default", login_form.username, login_form.password ) ) {
        Logger.info("Success!");
    }

The User in state.user will have an id corresponding to the value of the field in id\_field, and the username will match the username\_field. `state.user.get_object()` will return an instance of your entity.

## Using Almanna for session storage

Create an entity containing at least a `session_id` integer field, and a `session_data` text/blob field in your database. When the entity is generated, change it to subclass `AlmannaSession` instead of `Entity`, and add it to your `src/CMakeLists.txt` file. It may look something like this:

    using Almanna;
    using Ambition.Session;
    namespace ExampleApp.Model.DB {
        public class Session : AlmannaSession {
            public override string entity_name { owned get { return "session"; } }
            public override string session_id { get; set; }
            public override string session_data { get; set; }
        }
    }

In your application configuration, tell Session to use the new Almanna storable, and provide the type of the entity. In this example, we'll use ExampleApp.Model.DB.Session.

    session.storable = StorableAlmanna
    session.entity_type = ExampleAppModelDBSession

Sessions will now be loaded and stored from the table defined in your entity.