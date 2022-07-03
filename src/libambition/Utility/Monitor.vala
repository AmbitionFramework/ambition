/*
 * Monitor.vala
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
using Gee;
using Posix;

namespace Ambition.Utility {
	/**
	 * Monitor an application for changes, build if it does.
	 */
	public class Monitor : Object {
#if !WIN32
		private Log4Vala.Logger logger = Log4Vala.Logger.get_logger("Ambition.Utility.Monitor");
		private static const int timeout = 1000;
		private HashMap<string,FileMonitorEvent> changed_files { get; set; default = new HashMap<string,FileMonitorEvent>(); }
		private ArrayList<FileMonitor> monitor_list = null;
		private unowned Pid running_pid { get; set; }

		public int run() {
			var loop = new MainLoop();

			var project_dir = File.new_for_path(".");
			if (
				!project_dir.query_exists()
				|| project_dir.query_file_type(FileQueryInfoFlags.NONE) != FileType.DIRECTORY
			) {
				logger.error("Somehow, we are not in a project directory.");
			}

			int return_type = build_and_run();
			if ( return_type != 0 ) {
				return return_type;
			}

			var time = new TimeoutSource(timeout);
			time.set_callback(() => {
				if ( changed_files.size > 0 ) {
					foreach ( string file in changed_files.keys ) {
						logger.info( "File '%s' %s.".printf( file, changed_files[file].to_string().substring(21).down() ) );
					}
					changed_files = new HashMap<string,FileMonitorEvent>();
					build_and_run();
				}
				return true;
			});
			time.attach( loop.get_context() );

			loop.run();
			return 0;
		}

		private int build_monitors() {
			monitor_list = new ArrayList<FileMonitor>();
			try {
				ArrayList<string> directories = get_recursive_directories("src");
				directories.add("src");
				directories.add("config");
				foreach ( string path in directories ) {
					var dir_path = File.new_for_path(path);
					var monitor = dir_path.monitor_directory( FileMonitorFlags.NONE );
					monitor.changed.connect(on_file_change);
					monitor_list.add(monitor);
				}
			} catch ( Error e ) {
				logger.error( "Could not monitor directory", e );
				return 1;
			}
			return 0;
		}

		/**
		 * Fires when a 'changed' signal is fired from FileMonitor. Collects
		 * the event type and executes a build/restart when a file is changed.
		 * @param file The original changed file
		 * @param other_file Reference file (optional)
		 * @param event_type FileMonitor event type
		 */
		private void on_file_change( File file, File? other_file, FileMonitorEvent event_type ) {
			if (
				event_type == FileMonitorEvent.CREATED
				|| event_type == FileMonitorEvent.CHANGED
				|| event_type == FileMonitorEvent.DELETED
			) {
				changed_files[file.get_basename()] = event_type;
			}
		}

		/**
		 * Recurse into directories and return that list.
		 * @param path Start path to recurse from
		 * @return ArrayList<string>
		 */
		private ArrayList<string> get_recursive_directories( string path ) {
			var dirs = new ArrayList<string>();
			try {
				FileInfo file_info;
				var directory = File.new_for_path(path);
				var enumerator = directory.enumerate_children(
					FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, 0 );

				while ( ( file_info = enumerator.next_file() ) != null ) {
					if ( file_info.get_file_type() == FileType.DIRECTORY && !file_info.get_name().has_prefix(".") ) {
						string full_path = path + "/" + file_info.get_name();
						dirs.add(full_path);
						dirs.add_all( get_recursive_directories(full_path) );
					}
				}
			} catch (Error e) {
				logger.error( e.message );
			}
			return dirs;
		}

		/**
		 * Build and run current project.
		 */
		private int build_and_run() {
			// Disconnect signals
			if ( monitor_list != null ) {
				foreach ( FileMonitor monitor in monitor_list ) {
					monitor.cancel();
				}
			}

			var build = new Build();
			if ( build.meson_project() != 0 ) {
				re_monitor();
				return -1;
			}
			if ( build.build_project() != 0 ) {
				re_monitor();
				return -1;
			}

			if ( running_pid > 0 ) {
				// Kill old process
				Posix.kill( running_pid, Posix.SIGTERM );
			}
			Pid pid;
			var cur_dir = Environment.get_current_dir();
			Environment.set_current_dir( cur_dir.substring( 0, cur_dir.length - 5 ) );
			string application_name = get_application_name();
			string[] args = { "%s/build/src/%s-bin".printf( Environment.get_current_dir(), application_name ) };

			// Build child environment
			var env = new ArrayList<string>();
			foreach ( string k in Environment.list_variables() ) {
				if ( k != "_" ) {
					env.add( "%s=%s".printf( k, Environment.get_variable(k) ) );
				}
			}
			env.add( "_=" + args[0] );

			// Spawn webapp
			try {
				Process.spawn_async(
					".",
					args,
					env.to_array(),
					SpawnFlags.DO_NOT_REAP_CHILD,
					null,
					out pid
				);
			} catch (SpawnError wse) {
				logger.error( "Unable to run web application", wse );
				re_monitor();
				return 0;
			}
			this.running_pid = pid;

			int retval = re_monitor();
			if ( retval > 0 ) {
				return retval;
			}

			return 0;
		}

		private int re_monitor() {
			// Reconnect signals
			int return_type = build_monitors();
			if ( return_type > 0 ) {
				Posix.kill( running_pid, Posix.SIGTERM );
				return return_type;
			}
			return 0;
		}
#endif
	}
}
