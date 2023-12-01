{ ... }: {
    services.stalwart-mail = {
        enable = true;
	    settings = {
            macros = {
                base_path = "/var/lib/stalwart-mail";
                HOST = "mail.wouterjehee.com";
                DEFAULT_DOMAIN = "wouterjehee.com";
            };
            include.files = [
                "%{base_path}%/etc/common/tls.toml"
                # "%{base_path}%/etc/common/tracing.toml"
                "%{base_path}%/etc/common/sieve.toml"
                "%{base_path}%/etc/directory/sql.toml"
                "%{base_path}%/etc/imap/listener.toml"
                "%{base_path}%/etc/imap/settings.toml"
                "%{base_path}%/etc/jmap/auth.toml"
                "%{base_path}%/etc/jmap/listener.toml"
                "%{base_path}%/etc/jmap/oauth.toml"
                "%{base_path}%/etc/jmap/protocol.toml"
                "%{base_path}%/etc/jmap/push.toml"
                "%{base_path}%/etc/jmap/ratelimit.toml"
                # "%{base_path}%/etc/jmap/store.toml"
                "%{base_path}%/etc/jmap/websockets.toml"
                "%{base_path}%/etc/smtp/auth.toml"
                "%{base_path}%/etc/smtp/listener.toml"
                "%{base_path}%/etc/smtp/milter.toml"
                # "%{base_path}%/etc/smtp/queue.toml"
                "%{base_path}%/etc/smtp/remote.toml"
                # "%{base_path}%/etc/smtp/report.toml"
                # "%{base_path}%/etc/smtp/resolver.toml"
                "%{base_path}%/etc/smtp/session.toml"
                "%{base_path}%/etc/smtp/signature.toml"
                "%{base_path}%/etc/smtp/spamfilter.toml" 
            ];
            server = {
                hostname = "%{HOST}%";
                max-connections = 8192;
                socket = {
                    nodelay = true;
                    reuse-addr = true;
                    backlog = 1024;
                };
            };
        };
    };
}
