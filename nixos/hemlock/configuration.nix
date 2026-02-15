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

        ../../modules/dev/nvim
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
    environment.systemPackages = with pkgs; [
        git
        apacheHttpd
        just
        patchelf
        file
        sqlite
        systemctl-tui
        doas-sudo-shim
    ];
    system.stateVersion = "23.05";
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";
    networking.firewall = {
        enable = true;
        allowedTCPPorts = [
            22      # ssh
            80      # http
            443     # https
        ];
    };
}
