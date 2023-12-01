{ pkgs, ... }: {
    imports = [
        ../../modules/radicale.nix
        ../../modules/nginx.nix
		# ../../modules/stalwart-mail.nix
    ];
    boot.loader.grub = {
        enable = true;
        device = "/dev/vda";
    };
    environment.systemPackages = with pkgs; [
        git
        apacheHttpd
	    just
	    patchelf
    ];
    system.stateVersion = "23.05";
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";
    programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        configure.customRC = ''
            set expandtab
            set tabstop=4
            set softtabstop=4
            set shiftwidth=4
        '';
    };
    networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 22 80 443 ];
    };
    services.openssh = {
        enable = true;
        settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
        };
    };
    users = {
        users.admin = {
            isNormalUser = true;
            extraGroups = [
                "docker"
            ];
            openssh.authorizedKeys.keys = [
               "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCgwW3CKG28vJIpaQgdMr8y/Q6drSmo6id+A1KRwzhhfT8c3J7+S62zZHkNVbRFyn2PqVy6eBnZPP8I1vBreb4LwouF22NwDiuhvpju9cu6b2hjqUSuDaHwcNpB/HIqJfTKaHrbzVUHJRC/dXjs4azRZgIzG/d8RbAVkf8u1vT+MTIX3dGKLFhdw+ySK9uSlwfYK3XRst99GAA8aGz5rW9L0RmwaNgmIyMloM8fHUUZTM5pD5VouN9Gaf6lG2rbGAIxhxiUBM69X2sgejMMwNVlaGjIukNuffw6S4l64U4IyjEdzz51aC9Gya3MDuin+rgz+9cF+9ofcISttb6RWt6MqGfjlBlEhPFp5V56DD38zG/WFpnXkMM7ENXv51efFguPaVgYHJ83gmsKQ+n+yNOeeUjGF2f0h3mnOLTSPyo1BrorrPmWO59YWP3N+0EhFRoH3+/H7CVHm92oK0T0PLlJpaNVzxJSdzIPpfAIsTyT72MYfScgyUP1KS2gYzRibHk= wouter@rusty-desktop" 
            ];
        };
    };
    security = {
        sudo.enable = false;
        doas = {
            enable = true;
            extraRules = [{
                users = [ "admin" ];
                keepEnv = true;
                noPass = true;
            }];
        };
    };
}
