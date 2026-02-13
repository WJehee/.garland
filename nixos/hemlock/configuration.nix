{ pkgs, inputs, ... }: {
    imports = [
        ../../modules/sops.nix
        ../../disk/server.nix
        ../../modules/server/caddy.nix
        ../../modules/server/radicale.nix
        ../../modules/server/headless.nix
        ../../modules/server/immich.nix
        ../../modules/server/authelia.nix
        ../../modules/server/lldap.nix
        ../../modules/tailscale.nix
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
            rsync
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
    # Website deploy user
    users.users.decree = {
        isSystemUser = true;
        group = "deploy-decree";
        shell = "${pkgs.coreutils}/bin/false";
        openssh.authorizedKeys.keys = [
            # Key defind in Github secrets
            ''command="${pkgs.rrsync}/bin/rrsync /var/www/wouterjehee.com",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9Ak2oGjRlLkDPHwm8u59i3NkyBIQ/6r9KpkDt1jbbz wouter@foxglove''
        ];
    };
    users.groups.decree = {};
    systemd.tmpfiles.rules = [
        "d /var/www/wouterjehee.com 0755 deploy-decree deploy-decree -"
    ];
    services.loodsenboekje.enable = true;
}
