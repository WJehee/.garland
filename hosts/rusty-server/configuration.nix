{ inputs, pkgs, ... }: {
    imports = [
        ../../modules/boot.nix
        ../../modules/radicale.nix
    ];
    environment.systemPackages = with pkgs; [
        git
    ];
    system.stateVersion = "23.05";
    nixpkgs.config.allowUnfree = true;
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";

    programs.vim.enable = true;
    networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 22 80 443 5232 ];
    };
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
                addSSL = true;
                enableACME = true;
                root = "/var/www/wouterjehee.com";
            };
           "cal.wouterjehee.com" = {
               forceSSL = true;
               enableACME = true;
               locations."/" = {
                   proxyPass = "http://localhost:5232/";
                   extraConfig = ''
                       proxy_set_header X-Script-Name /radicale;
                       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                       proxy_pass_header Authorization;
                   '';
               };
           };
        };
    };

}
                       }
