{ ... }: {
    services.caddy = {
        enable = true;
        globalConfig = ''
            (authentik) {
                reverse_proxy /outpost.goauthentik.io/* localhost:9000

                forward_auth localhost:9000 {
                    uri /outpost.goauthentik.io/auth/caddy
                    copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Entitlements X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
                    trusted_proxies private_ranges
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
                reverse_proxy http://localhost:9000
            '';
            "app1.wouterjehee.com".extraConfig = ''
                route {
                    import authentik
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
