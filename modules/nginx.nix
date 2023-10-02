{ ... }: {
    security.acme = {
        acceptTerms = true;
        defaults.email = "dev.temporator@aleeas.com";
    };
    services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        virtualHosts = {
            "wouterjehee.com" = {
                forceSSL = true;
                enableACME = true;
                root = "/home/admin/wouterjehee.com";
                serverAliases = [ "cal.wouterjehee.com" ];
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
        };
    };
}
