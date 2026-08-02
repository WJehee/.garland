# Departure board server for 6767ov.dorusrijkers.eu
# Hemlock terminates TLS and auth, then proxies here over tailscale
{ config, ... }: let
    nixos = config.flake.modules.nixos;
    hm = config.flake.modules.homeManager;
in {
    flake.modules.nixos."hosts/dr-perron" = {
        imports = [
            ./_hardware-configuration.nix
            nixos.base
            nixos.home-manager
            nixos.server
            nixos."disk/server"
            nixos.tailscale
        ];

        networking.hostName = "dr-perron";
        boot.loader.grub = {
            enable = true;
            devices = [];
            efiSupport = true;
            efiInstallAsRemovable = true;
        };
        nix.settings.trusted-users = [ "admin" ];
        networking.firewall = {
            enable = true;
            allowedTCPPorts = [
                22      # ssh
            ];
            # Departure board is only reachable over tailscale
            interfaces."tailscale0".allowedTCPPorts = [ 6767 ];
        };

        home-manager.users.admin = {
            imports = [ hm.shell ];
            # DO NOT CHANGE THIS after first install
            home.stateVersion = "26.11";
            programs.home-manager.enable = true;
        };
    };
}
