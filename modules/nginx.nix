{ ... }: {
    security.acme = {
        acceptTerms = true;
        defaults.email = "dev.temporator@aleeas.com";
    };
    services.logrotate.settings.nginx.frequency = "daily";
    services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        virtualHosts = {
            "wouterjehee.com" = {
                forceSSL = true;
                enableACME = true;
                root = "/var/www/wouterjehee.com";
                serverAliases = [ 
                    "www.wouterjehee.com"
                    "cal.wouterjehee.com"
                    "ntfy.wouterjehee.com"
                ];
            };
            "cal.wouterjehee.com" = {
                forceSSL = true;
                useACMEHost = "wouterjehee.com";
                locations."/" = {
                    proxyPass = "http://localhost:5232/";
                    extraConfig = ''
                        proxy_set_header X-Script-Name /;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                        proxy_pass_header Authorization;
                    '';
                };
            };
            "ntfy.wouterjehee.com" = {
                forceSSL = true;
                useACMEHost = "wouterjehee.com";
                locations."/" = {
                    proxyPass = "http://localhost:2555";
                    extraConfig = ''
                        proxy_set_header X-Script-Name /;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                        proxy_pass_header Authorization;
                    '';
                };
            };
            "loodsenboekje.com" = {
                forceSSL = true;
                enableACME = true;
                serverAliases = [
                    "www.loodsenboekje.com"
                ];
                locations."/" = {
                    proxyPass = "http://localhost:1744";
                    extraConfig = ''
                        proxy_set_header X-Script-Name /;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                        proxy_pass_header Authorization;
                    '';
                };
            };
        };
    };
}
