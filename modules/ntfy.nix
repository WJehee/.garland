{ ... }: {
    services.ntfy-sh = {
        enable = true;
        settings = {
            base-url = "https://ntfy.wouterjehee.com";
            listen-http = ":2555";
            behind-proxy = true;

            auth-file = "/var/lib/ntfy-sh/user.db";
            auth-default-access = "deny-all";
        };
    };
}
