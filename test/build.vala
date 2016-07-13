/*
 * build.vala
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

public class BuildTest : Ambition.Testing.AbstractTestCase {
	public BuildTest() {
		base("Ambition.Build");
		add_test( "init", init );
		add_test( "parse_line", parse_line );
		add_test( "parse_build_config", parse_build_config );
	}

	public void init() {
		var obj = new Ambition.Build();
		assert( obj != null );
	}

	public void parse_line() {
		var b = new Ambition.Build();
		b.parse_line("# This is a comment");
		b.parse_line("target_version = 0.1");
		assert( b.target_version == "0.1" );
	}

	public void parse_build_config() {
		var b = new Ambition.Build();
		assert( b.target_version == null );
		assert( b.parse_build_config("assets/build.conf") == true );
		assert( b.target_version == "1.0.3" );
	}

}