{ config, ... }: {
    programs.firefox = {
	enable = true;
	profiles.wouter = {
            settings = {
		"dom.security.https_only_mode" = true;
	    };
	    search = {
		default = "DuckDuckGo";
		engines = {

		};
	    };
	};
        # preferences = {
	#     "extensions.pocket.enable" = false;
        # };
    };
}
