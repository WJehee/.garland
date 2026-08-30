# Homelab server
{ config, ... }: let
    nixos = config.flake.modules.nixos;
    hm = config.flake.modules.homeManager;
in {
    flake.modules.nixos."hosts/oleander" = { lib, ... }: {
        imports = [
            ./_hardware-configuration.nix
            nixos.base
            nixos.home-manager
            nixos.server
            nixos."disk/server"
            nixos.tailscale
            nixos."gpu/nvidia"

            nixos."services/caddy"
            nixos."services/gitea"
            nixos."services/immich"

            nixos.llm
            nixos.chatterbox
        ];

        networking.hostName = "oleander";
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
                80      # http
                443     # https
            ];
        };

        # Open WebUI binds to localhost, expose it through caddy
        services.caddy.virtualHosts."chat.wouterjehee.com".extraConfig = ''
            reverse_proxy http://localhost:9090
        '';
        services.open-webui.environment.WEBUI_URL = lib.mkForce "https://chat.wouterjehee.com";

        home-manager.users.admin = {
            imports = [ hm.shell ];
            # DO NOT CHANGE THIS after first install
            home.stateVersion = "26.11";
            programs.home-manager.enable = true;
        };
    };
}
