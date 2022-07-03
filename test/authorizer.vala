/*
 * authorizer.vala
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

public class AuthorizerTest {
	public static void add_tests() {
		Test.add_func("/ambition/authorizer/htpasswd", () => {
			var config = new Gee.HashMap<string,string>();
			config.set( "type", "Htpasswd" );
			config.set( "file", "assets/htpasswd" );

			var c = new Ambition.Authorization.Authorizer.Htpasswd();
			assert( c != null );
			c.init(config);
			Ambition.Authorization.IUser? user = c.authorize( "test", "foo" );
			assert( user != null );
			user = null;
			user = c.authorize( "bar", "test" );
			assert( user != null );
		});

		Test.add_func("/ambition/authorizer/htpasswd/user", () => {
			var u = new Ambition.Authorization.User.Htpasswd();
			u.id = 1;
			u.username = "test";
			assert( u.id == 1 );
			assert( u.username == "test" );

			u = new Ambition.Authorization.User.Htpasswd.with_params( 1, "test" );
			assert( u.id == 1 );
			assert( u.username == "test" );

			var s = u.serialize();
			assert( s == "1¬test" );

			u = new Ambition.Authorization.User.Htpasswd();
			u.deserialize(s);
			assert( u.username == "test" );
		});

		Test.add_func("/ambition/authorizer/flat", () => {
			var config = new Gee.HashMap<string,string>();
			config.set( "type", "Flat" );
			config.set( "file", "assets/flat_file" );

			var a = typeof(Ambition.Authorization.PasswordType.SHA1);
			var c = new Ambition.Authorization.Authorizer.Flat();
			assert( c != null );
			c.init(config);
			Ambition.Authorization.IUser user = c.authorize( "test", "foo" );
			assert( user != null );
			user = null;
			user = c.authorize( "bar", "test" );
			assert( user != null );
		});

		Test.add_func("/ambition/authorizer/flat/user", () => {
			var u = new Ambition.Authorization.User.Flat();
			u.id = 1;
			u.username = "test";
			assert( u.id == 1 );
			assert( u.username == "test" );

			u = new Ambition.Authorization.User.Flat.with_params( 1, "test" );
			assert( u.id == 1 );
			assert( u.username == "test" );

			var s = u.serialize();
			assert( s == "1¬test" );

			u = new Ambition.Authorization.User.Flat();
			u.deserialize(s);
			assert( u.username == "test" );
		});

		Test.add_func("/ambition/authorizer/builder", () => {
			var config = Ambition.Config.get_instance();
			config.config_hash = new Gee.HashMap<string,string>();
			config.config_hash.set( "authorization.foo.type", "Htpasswd" );
			config.config_hash.set( "authorization.bar.type", "Htpasswd" );

			Ambition.Authorization.Builder.build_authorizers();
			assert( Ambition.App.authorizers != null );
			assert( Ambition.App.authorizers.size == 2 );
		});

		Test.add_func("/ambition/authorizer/authorize", () => {
			var config = Ambition.Config.get_instance();
			config.config_hash = new Gee.HashMap<string,string>();
			config.config_hash.set( "authorization.foo.type", "Htpasswd" );
			config.config_hash.set( "authorization.foo.file", "assets/htpasswd" );

			Ambition.Authorization.Builder.build_authorizers();
			var c = new Ambition.Authorization.Authorize();
			bool authorize_success = c.authorize( "foo", "test", "foo" );
			assert( authorize_success == true ); 	// Did we authenticate
			assert( c.user != null );				// Did we create a user
			assert( c.user.id > 0 );				// Does the user have an ID
			assert( c.user.username != null );		// Does the user have a username
		});
	}
}
