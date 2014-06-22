public static int main( string[] args ) {
	Log4Vala.init("config/log4vala.conf");
	var app = new %%namespace%%.Application();
	app.run(args);
	return 0;
}
