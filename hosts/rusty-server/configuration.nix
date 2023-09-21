{ inputs, pkgs, ... }: {
    imports = [
        ../../modules/boot.nix
    ];
    environment.systemPackages = with pkgs; [
        git
    ];
    system.stateVersion = "23.05";
    nixpkgs.config.allowUnfree = true;
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";

    programs.neovim.enable = true;
    #networking.firewall = {
    #    enable = true;
    #};
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
