/*
 * AlmannaTest.vala
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

using Ambition;
using Ambition.PluginSupport;
using Gee;

void main (string[] args) {
	Test.init( ref args );
	add_tests();
	Test.run();
}

public static void add_tests() {
	Test.add_func("/ambition/plugin/almanna", () => {
		Ambition.Config.set_value( "test", "1" );
		Ambition.Config.set_value( "almanna.provider", "SQLite" );
		Ambition.Config.set_value( "almanna.connection_string", "SQLite://DB_DIR=.;DB_NAME=test" );

		Almanna.Repo.add_entity( typeof(UserEntity) );
		var plugin = new AlmannaPlugin();
		plugin.register_plugin();
		Authorization.Builder.build_authorizers();
	});

	Test.add_func("/ambition/authorizer/almanna", () => {
		var config = get_config();

		var c = new Ambition.Authorization.Authorizer.Almanna();
		assert( c != null );
		c.init(config);
		Ambition.Authorization.IUser user = c.authorize( "foobar", "passw3rd" );
		assert( user != null );
		user = null;
		user = c.authorize( "foobar", "passw3rd" );
		assert( user != null );
	});

	Test.add_func("/ambition/authorizer/almanna/user", () => {
		var config = get_config();

		var u = new Ambition.Authorization.User.Almanna.with_params( config, 1, "foobar" );
		assert( u.id == 1 );
		assert( u.username == "foobar" );

		var s = u.serialize();
		assert( s == "1¬foobar" );

		u = new Ambition.Authorization.User.Almanna();
		u.deserialize(s);
		assert( u.username == "foobar" );
	});
}

public static HashMap<string,string> get_config() {
	var config = new HashMap<string,string>();
	config.set( "type", "Almanna" );
	config.set( "password_type", "SHA1" );
	config.set( "entity_type", "UserEntity" );
	config.set( "id_field", "user_id" );
	return config;
}