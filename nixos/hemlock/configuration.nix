{ pkgs, inputs, ... }: {
    imports = [
        ../../disk/server.nix

        ../../modules
        ../../modules/dev

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
    nix.settings.trusted-users = [ "admin" ];
    environment.systemPackages = with pkgs; [
        apacheHttpd
        sqlite
    ];
    networking.firewall = {
        enable = true;
        allowedTCPPorts = [
            22      # ssh
            80      # http
            443     # https
        ];
    };
}
