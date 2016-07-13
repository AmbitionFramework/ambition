/*
 * serializer-test-classes.vala
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

public class TestStringObject : Object {
	public string foo { get; set; default = "bar"; }
}

public class TestStringUnderscoreObject : Object {
	public string foo_baz { get; set; default = "bar"; }
}

public class TestIntObject : Object {
	public int foo { get; set; default = 42; }
}

public class TestDoubleObject : Object {
	public double foo { get; set; default = 62.31; }
}

public class TestBoolObject : Object {
	public bool foo { get; set; default = true; }
}

public class TestStringArrayObject : Object {
	public string[] foo { get; set; default = { "bar", "baz" }; }
}

public class TestStringArrayListObject : Object {
	public Gee.ArrayList<string> foo { get; set; default = new Gee.ArrayList<string>(); }

	public TestStringArrayListObject() {
		foo.add("bar");
		foo.add("baz");
	}
}

public class TestObjectObject : Object {
	public Object bar { get; set; default = new TestStringArrayObject(); }
}

public class TestEverythingObject : Object {
	public string foo_baz { get; set; default = "bar"; }
	public int some_int { get; set; default = 42; }
	public bool is_something { get; set; default = false; }
	public string[] list_of_things { get; set; default = { "thing", "another", "so wow" }; }
	public Object super_container { get; set; default = new TestEverythingContainerObject(); }
}

public class TestEverythingContainerObject : Object {
	public Object container { get; set; default = new TestStringArrayListObject(); }
	public string example { get; set; default = "I am here"; }
}

public class TestIgnoreObject : Object {
	public string not_ignored { get; set; default = "woohoo"; }
	[Description( blurb = "ignore" )]
	public string ignored { get; set; default = "boo"; }
}

public class TestRenameObject : Object {
	[Description( nick = "renamed" )]
	public string something { get; set; default = "woohoo"; }
}