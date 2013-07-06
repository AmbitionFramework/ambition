/*
 * IPluginService.vala
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

using Gee;
namespace Ambition.Plugin {
	/**
	 * Provides a plugin service.
	 */
	public interface IPluginService : Object {
		public abstract HashMap<string,string> config { get; set; }

		public abstract File? retrieve_plugin( string plugin_name, string? version = null ) throws Error;

		public abstract ArrayList<PluginResult> search_plugin( string plugin_name ) throws Error;

		public abstract ArrayList<PluginResult> available_plugins() throws Error;

		public abstract ArrayList<PluginResult> check_outdated_plugin( HashMap<string,string> installed_plugins );

		public abstract PluginManifest? get_manifest( string plugin_name );
	}
}
