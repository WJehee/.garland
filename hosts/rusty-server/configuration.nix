{ lib, pkgs, ... }: {
    imports = [
        ../../modules/radicale.nix
        ../../modules/nginx.nix
        ../../modules/ntfy.nix
    ];
    boot.loader.grub = {
        enable = true;
        device = "/dev/vda";
    };
    nix.settings = {
        trusted-users = lib.mkOptionDefault [
            "admin"
        ];
        experimental-features = [
            "nix-command"
            "flakes"
        ];
    };
    environment = {
        sessionVariables = {
            GIT_EDITOR = "nvim";
            VISUAL = "nvim";
        };
        systemPackages = with pkgs; [
            git
            apacheHttpd
            just
            patchelf
            file
            sqlite
        ];
    };
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
        allowedTCPPorts = [
            22 80 443       # ssh, https, https
        ];
    };
    services.openssh = {
        enable = true;
        settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
        };
    };
    users.users.admin = {
        isNormalUser = true;
        extraGroups = [
            "docker"
        ];
        openssh.authorizedKeys.keys = [
           "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAV7jskmE1QgWJARUS4VtDMscikpRYVGRHZBEWculRLd wouter@rusty-desktop"
           "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsXnqF+WswS3iXQt8IlhoHlbvBd2wXmjX1txY73OkevQH/MchQ2+qrvUjFYLJ6TXXyokShvvfcWCNk/hlIOvP1iqXEHmW5IyBLPkkXCzeCBN6B+rNlcNlYJuH9ymjt+rKDFS5w5hdXipRCoj/VQDjAN246bTwVtQD85SqeYoBCzXHV6+O+hsmM5uCn1uQHaz6zQ0b5/BgU5EzKwDP2Bh7moWUh+WpNPAJEQXzf3lMA5Zc/KcfP5roECoxj/5JYVVhYCstMwA94LfOzmUD9mYtQj67EFlJ5fCYbO7bmT87KR4MeNFB2zUJHnnxFb9EOFdZX8nMHb9qgXEtlqwbYjuo5XODfLPph8Q+idLw3GOOVKPBakas0l1S8NftJ6TeAEDHyB7gWFnyuf4aydKWWikTPee4aBroFVVjIbqsjThfYMccw3vIkokbYEGlp0CUA0HT100hhGuOMmixFw0n+2jP70jVDFWNnyALPknDqBiagedUXWBZ6kPcQWOqGC+rkNQM="
        ];
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
    services.loodsenboekje.enable = true;
}
