{ inputs, pkgs, ... }: {
    imports = [
        ../../modules/boot.nix
        ../../modules/radicale.nix
    ];
    environment.systemPackages = with pkgs; [
        git
    ];
    system.stateVersion = "23.05";
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";

    programs.neovim.enable = true;
    networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 22 80 443 5232 ];
    };

    services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
        settings.KbdInteractiveAuthentication = false;
        settings.PermitRootLogin = "no";
    };
    users.users.admin = {
        isNormalUser = true;
        extraGroups = [
            # "wheel", not needed with doas
            "docker"
        ];
        openssh.authorizedKeys.keys = [
           "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCgwW3CKG28vJIpaQgdMr8y/Q6drSmo6id+A1KRwzhhfT8c3J7+S62zZHkNVbRFyn2PqVy6eBnZPP8I1vBreb4LwouF22NwDiuhvpju9cu6b2hjqUSuDaHwcNpB/HIqJfTKaHrbzVUHJRC/dXjs4azRZgIzG/d8RbAVkf8u1vT+MTIX3dGKLFhdw+ySK9uSlwfYK3XRst99GAA8aGz5rW9L0RmwaNgmIyMloM8fHUUZTM5pD5VouN9Gaf6lG2rbGAIxhxiUBM69X2sgejMMwNVlaGjIukNuffw6S4l64U4IyjEdzz51aC9Gya3MDuin+rgz+9cF+9ofcISttb6RWt6MqGfjlBlEhPFp5V56DD38zG/WFpnXkMM7ENXv51efFguPaVgYHJ83gmsKQ+n+yNOeeUjGF2f0h3mnOLTSPyo1BrorrPmWO59YWP3N+0EhFRoH3+/H7CVHm92oK0T0PLlJpaNVzxJSdzIPpfAIsTyT72MYfScgyUP1KS2gYzRibHk= wouter@rusty-desktop" 
        ];
    };
    security.sudo.enable = false;
    security.doas.enable = true;
    security.doas.extraRules = [{
        users = [ "admin" ];
        keepEnv = true;
        persist = true;
    }];

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
