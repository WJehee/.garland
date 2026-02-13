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
            "wouterjehee.com".extraConfig = ''
                root * /var/www/wouterjehee.com
                encode gzip
                file_server
            '';
            "cal.wouterjehee.com".extraConfig = ''
                reverse_proxy http://localhost:5232
            '';
            "img.wouterjehee.com".extraConfig = ''
                reverse_proxy http://localhost:2283
            '';
            "auth.wouterjehee.com".extraConfig = ''
                reverse_proxy http://localhost:9091
            '';
            "ldap.wouterjehee.com".extraConfig = ''
                reverse_proxy http://localhost:17170
            '';
            "app1.wouterjehee.com".extraConfig = ''
                route {
                    import authelia
                    reverse_proxy localhost:4000
                }
            '';

            "dorusrijkers.eu".extraConfig = ''
                root * /var/www/dorusrijkers.eu
                encode gzip
                file_server
            '';
            "loodsenboekje.dorusrijkers.eu".extraConfig = ''
                reverse_proxy http://localhost:1744
            '';
        };
    };
}
