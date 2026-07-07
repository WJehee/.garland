# VPS server
{ config, ... }: let
    nixos = config.flake.modules.nixos;
    hm = config.flake.modules.homeManager;
in {
    flake.modules.nixos."hosts/hemlock" = { pkgs, ... }: {
        imports = [
            ./_hardware-configuration.nix
            nixos.base
            nixos.home-manager
            nixos.server
            nixos."disk/server"
            nixos.tailscale

            nixos."services/authelia"
            nixos."services/caddy"
            nixos."services/lldap"
            nixos."services/radicale"
            nixos."services/immich"
            nixos."services/glitchtip"

            nixos."services/projects"
        ];

        networking.hostName = "hemlock";
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

        home-manager.users.admin = {
            imports = [ hm.shell ];
            # DO NOT CHANGE THIS after first install
            home.stateVersion = "24.11";
            programs.home-manager.enable = true;
        };
    };
}
