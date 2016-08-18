/*
 * BacktraceReporter.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2015 Sensical, Inc.
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
namespace Ambition {
	/**
	 * Intercept and report backtraces.
	 */
	public class BacktraceReporter : Object {
		public static BacktraceReporter static_reporter;
		public ErrorHandler handler = null;
		public Dispatcher dispatcher = null;
		public State state = null;

		private int total_count = 127;
		private int skip = 4;

		public BacktraceReporter( ErrorHandler handler, Dispatcher dispatcher ) {
			this.handler = handler;
			this.dispatcher = dispatcher;
		}

		/**
		 * Install signal handlers.
		 */
		public void install_signals() {
			static_reporter = this;
			Process.@signal( ProcessSignal.SEGV, signal_handler );
			Process.@signal( ProcessSignal.ABRT, signal_handler );
			Process.@signal( ProcessSignal.TRAP, signal_handler );
			Process.@signal( ProcessSignal.FPE, signal_handler );
		}

		/**
		 * Handle signal
		 * @param signal_int int representing signal from OS
		 */
		public static void signal_handler( int signal_int ) {
			ParsedBacktrace trace = static_reporter.obtain_trace(signal_int);
			if ( static_reporter.handler != null ) {
				static_reporter.handler( static_reporter.state, trace );
			} else {
				trace.report();
			}
			Process.exit(1);
		}

		public Result default_error_handler( State state, ParsedBacktrace trace ) {
			StringBuilder sb = new StringBuilder();
			foreach ( var f in trace.frames ) {
				if ( f.function == "??" ) {
					sb.append( "<div>Library: (%s) [%s]</div>".printf( f.raw, f.address ) );
				} else {
					sb.append( "<div>%s (%s:%d) [%s]</div>".printf( f.function, f.filename, f.line, f.address ) );
				}
			}
			return new Ambition.CoreView.RawString("""<html><head><title>Error</title><style type="text/css">
		body { background-color: #bfbfbc; font-family: verdana; font-size: 12px }
		h1 { text-align: center; padding: 20px !important; margin: 0; }
		h2 { margin: 0 0 8px 0; padding: 0;}
		table { border: 1px solid #ddd; width: 622px; table-layout:fixed; border-collapse: collapse; }
		td,th { border: 1px solid #ddd; padding: 8px; font-size: 12px; word-wrap:break-word }
		th { text-align: left; font-weight: bold }
		.box { margin: 20px auto; width: 640px; padding: 8px; background-color: #fff; border: 2px solid #888; }
		#param_box { display: none; padding-top: 8px }
		#footer { font-size: small; color: #333; margin: 0; padding: 5px 10%; border-top: 1px solid #888; text-align: right; }
	</style></head><body><div class="box"><h1>Error</h1></div>
	<div class="box"><div><b>%s</b></div>%s</div></body></html>""".printf( trace.readable_signal, sb.str ), 500);
		}

		protected ParsedBacktrace obtain_trace(int signal_int) {
	    	void*[] array = new void*[total_count];
	#if VALA_0_26
	    	var size = Linux.Backtrace.@get(array);
	    	var strings = Linux.Backtrace.symbols(array);
	#else
	    	int size = Linux.backtrace( array, total_count );
	    	unowned string[] strings = Linux.backtrace_symbols( array, size );
	    	strings.length = size;
	#endif
			int64[] addresses = (int64[]) array;

			var trace = new ParsedBacktrace();

			// Obtain frames
			for( int i = skip; i < size; i++ ) {
				int64 address = addresses[i];
				string line = strings[i];
				var parsed_frame = parse_frame(address, line);
				trace.frames.add(parsed_frame);
			}

			// Obtain readable signal
			switch((ProcessSignal) signal_int) {
				case ProcessSignal.SEGV:
					trace.signal_name = "SEGV";
					trace.readable_signal = "Segmentation Fault";
					break;
				case ProcessSignal.TRAP:
					trace.signal_name = "TRAP";
					trace.readable_signal = "Unhandled Error";
					break;
				case ProcessSignal.ABRT:
					trace.signal_name = "ABRT";
					trace.readable_signal = "Abort/Failed Assert";
					break;
				case ProcessSignal.FPE:
					trace.signal_name = "FPE";
					trace.readable_signal = "Floating Point Exception";
					break;
				default:
					trace.signal_name = "";
					trace.readable_signal = "Unknown";
					break;
			}

			return trace;
		}

		private string get_module () {
			var path = new char[1024];
			Posix.readlink( "/proc/self/exe", path );
			return (string) path;
		}

		private ParsedFrame parse_frame( int64 address, string line ) {
			var parsed_frame = new ParsedFrame();

			// Parse address
			int start = line.index_of("[") + 1;
			int end = line.index_of("]") - start;
			parsed_frame.address = line.substring( start, end ).strip();

			// Get raw line
			parsed_frame.raw = line.substring( 0, start - 1 ).strip();

			// Parse function
			string module_name = get_module();
			extract_function_from_address( parsed_frame, module_name );

			return parsed_frame;
		}

		private void extract_function_from_address( ParsedFrame parsed_frame, string module ) {
			var addr2line = "addr2line -f -e %s %s".printf(module, parsed_frame.address);
			string[] parts = get_command_output(addr2line).split("\n");
			string[] file_parts = parts[1].split(":");
			parsed_frame.function = parts[0];
			parsed_frame.filename = file_parts[0];
			parsed_frame.line = int.parse( file_parts[1] );
		}

		private string? get_command_output( string command_line ) {
			try {
				int code;
				string output;
				string error;
				Process.spawn_command_line_sync( command_line, out output, out error, out code );
				return output.strip();
			} catch (Error e) {
				stderr.printf( "Unable to execute command line %s: %s\n", command_line, e.message );
			}
			return null;
		}
	}

	public class ParsedFrame {
		public string address { get; set; }
		public string function { get; set; }
		public string filename { get; set; }
		public int line { get; set; }
		public string raw { get; set; }
	}

	public class ParsedBacktrace {
		public ArrayList<ParsedFrame> frames { get; set; default = new ArrayList<ParsedFrame>(); }
		public string signal_name { get; set; }
		public string readable_signal { get; set; }

		public void report() {
			stdout.printf( "Exception: %s (%s)\n", readable_signal, signal_name );
			foreach ( var f in frames ) {
				if ( f.function == "??" ) {
					stdout.printf( "  Library: (%s) [%s]\n", f.raw, f.address);
				} else {
					stdout.printf( "  %s (%s:%d) [%s]\n", f.function, f.filename, f.line, f.address);
				}
			}
		}
	}
}