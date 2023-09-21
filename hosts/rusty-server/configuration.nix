{ inputs, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        git
    ];
    #networking.firewall = {
    #    enable = true;
    #};
    security.acme = {
        acceptTerms = true;
        email = "dev.temporator@aleeas.com";
    };
    services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        virtualHosts = {
            "wouterjehee.com" = {
                addSSL = true;
                enableACME = true;
                root = "/var/www/wouterjehee.com";
            };
            "cal.wouterjehee.com" = {
                forceSSL = true;
                enableACME = true;
                locations."/" = {
                    proxyPass = "http://"localhost:5232/;
                    extraConfig = ''
                        proxy_set_header X-Script-Name /radicale;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                        proxy_set_header Host $http_host;
                        proxy_pass_header Authorization;
                    '';
                };
            };
        };
    };
    services.radicale = {
        enable = true;
        settings = {
            server = {
                hosts = [ "0.0.0.0:5232" "[::]:5232" ];
            };
            auth = {
                type = "htpasswd";
                htpasswd_filename = "/etc/radicale/users";
                htpasswd_encryption = "bcrypt";
            };
            storage = {
                filesystem_folder = "/var/lib/radicale/collections";
            };
        };
    };
# services.stalwart-mail = {
#    enable = true;
# };
                       }
