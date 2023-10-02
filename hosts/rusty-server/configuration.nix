{ inputs, pkgs, ... }: {
    imports = [
        ../../modules/boot.nix
        ../../modules/radicale.nix
        ../../modules/nginx.nix
    ];
    environment.systemPackages = with pkgs; [
        git
        apacheHttpd
    ];
    system.stateVersion = "23.05";
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";

    programs.neovim.enable = true;
    networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 22 80 443 ];
    };

    services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
        settings.KbdInteractiveAuthentication = false;
        settings.PermitRootLogin = "no";
    };
    users.users = {
        admin = {
            isNormalUser = true;
            extraGroups = [
                "docker"
            ];
            openssh.authorizedKeys.keys = [
               "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCgwW3CKG28vJIpaQgdMr8y/Q6drSmo6id+A1KRwzhhfT8c3J7+S62zZHkNVbRFyn2PqVy6eBnZPP8I1vBreb4LwouF22NwDiuhvpju9cu6b2hjqUSuDaHwcNpB/HIqJfTKaHrbzVUHJRC/dXjs4azRZgIzG/d8RbAVkf8u1vT+MTIX3dGKLFhdw+ySK9uSlwfYK3XRst99GAA8aGz5rW9L0RmwaNgmIyMloM8fHUUZTM5pD5VouN9Gaf6lG2rbGAIxhxiUBM69X2sgejMMwNVlaGjIukNuffw6S4l64U4IyjEdzz51aC9Gya3MDuin+rgz+9cF+9ofcISttb6RWt6MqGfjlBlEhPFp5V56DD38zG/WFpnXkMM7ENXv51efFguPaVgYHJ83gmsKQ+n+yNOeeUjGF2f0h3mnOLTSPyo1BrorrPmWO59YWP3N+0EhFRoH3+/H7CVHm92oK0T0PLlJpaNVzxJSdzIPpfAIsTyT72MYfScgyUP1KS2gYzRibHk= wouter@rusty-desktop" 
               "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsXnqF+WswS3iXQt8IlhoHlbvBd2wXmjX1txY73OkevQH/MchQ2+qrvUjFYLJ6TXXyokShvvfcWCNk/hlIOvP1iqXEHmW5IyBLPkkXCzeCBN6B+rNlcNlYJuH9ymjt+rKDFS5w5hdXipRCoj/VQDjAN246bTwVtQD85SqeYoBCzXHV6+O+hsmM5uCn1uQHaz6zQ0b5/BgU5EzKwDP2Bh7moWUh+WpNPAJEQXzf3lMA5Zc/KcfP5roECoxj/5JYVVhYCstMwA94LfOzmUD9mYtQj67EFlJ5fCYbO7bmT87KR4MeNFB2zUJHnnxFb9EOFdZX8nMHb9qgXEtlqwbYjuo5XODfLPph8Q+idLw3GOOVKPBakas0l1S8NftJ6TeAEDHyB7gWFnyuf4aydKWWikTPee4aBroFVVjIbqsjThfYMccw3vIkokbYEGlp0CUA0HT100hhGuOMmixFw0n+2jP70jVDFWNnyALPknDqBiagedUXWBZ6kPcQWOqGC+rkNQM="
            ];
        };
    };
    security.sudo.enable = false;
    security.doas.enable = true;
    security.doas.extraRules = [{
        users = [ "admin" ];
        keepEnv = true;
        persist = true;
    }];
}
