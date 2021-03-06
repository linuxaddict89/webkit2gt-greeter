
using GLib;

namespace Luminos {
	public static int main(string[] args) {
		bool do_show_version = false;
		bool do_debug = false;
		bool dev = false;
		string? current_path = Posix.realpath(GLib.Environment.find_program_in_path(args[0]));

		OptionEntry versionOption = { "version", 'v', 0, OptionArg.NONE, ref do_show_version,
			                      /* Help string for command line --version flag */
			                      _("Show release version"), null };
		OptionEntry debugOption = { "debug", 'd', 0, OptionArg.NONE, ref do_debug,
			                    _("Enable debugging features"), null };
		OptionEntry devOption = { "dev", 'c', 0, OptionArg.NONE, ref dev,
			                  _("Running in development mode"), null };
		OptionEntry[] options = { versionOption, debugOption, devOption };

		debug("Loading command line options");
		var c = new OptionContext("- Webkit2gtk Greeter");
		c.add_main_entries(options, "io.github.luminos-greeter");
		c.add_group(Gtk.get_option_group(true));

		try {
			c.parse(ref args);
		} catch(Error e) {
			error("%s\n", e.message);
			/* Text printed out when an unknown command-line argument provided */
			error("Run '%s --help' to see a full list of available command line options.", args[0]);
			return Posix.EXIT_FAILURE;
		}

		if(do_show_version) {
			/* Note, not translated so can be easily parsed */
			//  stderr.printf(Constants.GETTEXT_PACKAGE + " %s\n", Constants.VERSION);
			return Posix.EXIT_SUCCESS;
		}
		AppOptions opts = {false};
		opts.debug = do_debug;
		opts.current_path = current_path;

		if(do_debug) {
			Environment.set_variable("G_MESSAGE_DEBUG", "all", true);
		}

		GreeterApplication app = new GreeterApplication(opts);
		return app.run(args);
	}
}
