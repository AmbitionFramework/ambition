/*
 * UserEntity.vala
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

using Almanna;
public class UserEntity : Almanna.Entity {
	public int user_id { get; set; }
	public string username { get; set; }
	public string password { get; set; }
	public string status { get; set; default = "New"; }

	public override void register_entity() {
		add_column( new Column<int>.with_name_type( "user_id", "int" ) );
		add_column( new Column<string>.with_name_type( "username", "varchar" ) );
		add_column( new Column<string>.with_name_type( "password", "varchar" ) );
		add_column( new Column<string>.with_default_value( "status", "varchar", "New" ) );
		try {
			set_primary_key("user_id");
			add_unique_constraint( "username", { "username" } );
		} catch ( EntityError ee ) {
			stderr.printf( ee.message );
		}
	}
}