{ pkgs, inputs, ... }: {
    imports = [
        ../../modules/sops.nix
        ../../disk/server.nix
        ../../modules/tailscale.nix

        ../../modules/server/caddy.nix
        ../../modules/server/radicale.nix
        ../../modules/server/headless.nix
        ../../modules/server/immich.nix
        ../../modules/server/authelia.nix
        ../../modules/server/lldap.nix
        ../../modules/server/projects.nix
    ];
    boot.loader.grub = {
        enable = true;
        devices = [];
        efiSupport = true;
        efiInstallAsRemovable = true;
    };
    nix.settings = {
        trusted-users = [
            "admin"
        ];
        experimental-features = [
            "nix-command"
            "flakes"
        ];
    };
    environment = {
        sessionVariables = {
            EDITOR = "nvim";
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
            systemctl-tui
            doas-sudo-shim
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
            22      # ssh
            80      # http
            443     # https
        ];
    };
}
