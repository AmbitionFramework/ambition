/*
 * test-runner.vala
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

/*
 * Any time you add a test, you're going to have to add the method, too.
 */

void main ( string[] args ) {
	Test.init( ref args );

	AppTest.add_tests();
	CookieTest.add_tests();
	EngineTest.add_tests();
	SessionTest.add_tests();
	DispatcherTest.add_tests();
	TemplateCompilerTest.add_tests();
	PluginManifestTest.add_tests();

	PasswordTypeTest.add_tests();
	AuthorizerTest.add_tests();

	FormTest.add_tests();
	FormFieldTest.add_tests();
	FormValidatorTest.add_tests();

	StashTest.add_tests();
	ControllerStaticTest.add_tests();
	HttpMethodTest.add_tests();
	ConfigTest.add_tests();
	RequestTest.add_tests();

	CoreViewFileTest.add_tests();
	CoreViewNoneTest.add_tests();
	CoreViewRedirectTest.add_tests();
	CoreViewJsonTest.add_tests();
	CoreViewRawStringTest.add_tests();

	PluginLoaderTest.add_tests();
	ActionBuilderTest.add_tests();

	Test.run();
}