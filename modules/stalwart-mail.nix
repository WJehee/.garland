{ ... }: {
    services.stalwart-mail = {
        enable = true;
	settings = {
	    include.files = [
		"/opt/stalwart-mail/etc/config.toml"
	    ];
	    global.tracing = {};
	    queue = {};
	    report = {};
	    resolver = {};
	    store = {};
        };
    };
}
