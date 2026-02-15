{ ... }: {
    services.caddy = {
        enable = true;
        extraConfig = ''
            (authelia) {
                forward_auth localhost:9091 {
                    uri /api/authz/forward-auth
                    copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
                }
            }
        '';
        virtualHosts = {
            # wouterjehee.com public site
            "wouterjehee.com".extraConfig = ''
                root * /var/www/wouterjehee.com
                encode gzip
                file_server
            '';
            # Auth services
            "auth.wouterjehee.com".extraConfig = ''
                reverse_proxy http://localhost:9091
            '';
            "ldap.wouterjehee.com".extraConfig = ''
                route {
                    import authelia
                    reverse_proxy http://localhost:17170
                }
            '';
            # Self hosted services behind auth
            "cal.wouterjehee.com".extraConfig = ''
                route {
                    import authelia
                    reverse_proxy http://localhost:5232
                }
            '';
            "img.wouterjehee.com".extraConfig = ''
                route {
                    import authelia
                    reverse_proxy http://localhost:2283
                }
            '';

            # dorusrijkers.eu public site
            "dorusrijkers.eu".extraConfig = ''
                root * /var/www/dorusrijkers.eu
                encode gzip
                file_server
            '';
            # Auth service
            "auth.dorusrijkers.eu".extraConfig = ''
                reverse_proxy http://localhost:9091
            '';
            # Services
            "loodsenboekje.dorusrijkers.eu".extraConfig = ''
                reverse_proxy http://localhost:1744
            '';
            "test.dorusrijkers.eu".extraConfig = ''
                reverse_proxy http://foxglove:4000
            '';
        };
    };
}
