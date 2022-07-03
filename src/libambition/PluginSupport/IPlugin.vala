/*
 * IPlugin.vala
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

namespace Ambition.PluginSupport {

	/**
	 * Interface for defining a new Ambition plugin.
	 */
	public interface IPlugin : Object {
		/**
		 * Name of the plugin.
		 */
		public abstract string name { get; }

		/**
		 * Method called before instantiation, to determine the type of the
		 * plugin.
		 */
		// public abstract static Type init_plugin();

		/**
		 * Method called when a plugin is first created, to allow a plugin
		 * to initialize any default values or instantiate other components.
		 */
		public abstract void register_plugin();

		/**
		 * Hook method called when application first starts. This method will
		 * only run once.
		 */
		public virtual void on_application_start( Dispatcher dispatcher ) {}

		/**
		 * Hook method called after the engine receives a request, but before a
		 * request is run through through the dispatcher.
		 */
		public virtual void on_request_dispatch( State state ) {}

		/**
		 * Hook method called after the dispatcher has received a request, but
		 * before the response is sent from the engine.
		 */
		public virtual void on_request_render( State state ) {}

		/**
		 * Hook method called at the end of a request, after the response has
		 * been rendered.
		 */
		public virtual void on_request_end( State state ) {}

		/**
		 * Hook method called when application exits gracefully.
		 */
		public virtual void on_application_end( Dispatcher dispatcher ) {}
	}
}
