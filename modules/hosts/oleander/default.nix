# Homelab server. The hardware is not settled yet; an Intel NUC is the
# likely candidate, so the GPU module is the Intel one and jellyfin
# transcodes through VA-API on the iGPU. Revisit both when the machine is
# bought.
{ config, ... }: let
    nixos = config.flake.modules.nixos;
    hm = config.flake.modules.homeManager;
in {
    flake.modules.nixos."hosts/oleander" = {
        imports = [
            ./_hardware-configuration.nix
            nixos.base
            nixos.home-manager
            nixos.server
            nixos."disk/server"
            nixos."gpu/intel"
            nixos.tailscale

            nixos."services/caddy"
            nixos."services/gitea"
            nixos."services/immich"
            # Jellyfin, Seerr, Navidrome and the arr stack, from wreath
            nixos.media
        ];

        networking.hostName = "oleander";
        boot.loader.grub = {
            enable = true;
            devices = [];
            efiSupport = true;
            efiInstallAsRemovable = true;
        };
        networking.firewall = {
            enable = true;
            allowedTCPPorts = [
                22      # ssh
                80      # http
                443     # https
            ];
        };

        # Hardware transcoding is left to the host by wreath's jellyfin
        # module, since it depends on the GPU: VA-API on the intel iGPU, on
        # its only render node. Only written to encoding.xml on first start,
        # later changes are made in the jellyfin dashboard.
        services.jellyfin.hardwareAcceleration = {
            enable = true;
            type = "vaapi";
            device = "/dev/dri/renderD128";
        };

        home-manager.users.admin = {
            imports = [ hm.shell ];
            # DO NOT CHANGE THIS after first install
            home.stateVersion = "26.11";
            programs.home-manager.enable = true;
        };
    };
}
