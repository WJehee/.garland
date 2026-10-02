{
    # Jellyfin streams the movie, tv and music libraries. It is the one
    # user-facing service in the stack, so it gets a public caddy virtual host.
    flake.modules.nixos.media = { lib, ... }: let
        media = import ./_lib.nix;
    in {
        services.caddy.virtualHosts."jellyfin.${media.domain}".extraConfig = ''
            reverse_proxy http://localhost:8096
        '';

        services.jellyfin = {
            enable = true;
            group = media.group;
            # Hardware transcoding is left to the host, because the device and
            # method depend on its GPU: intel/amd hosts set
            # hardwareAcceleration = { enable = true; type = "vaapi"; device =
            # "/dev/dri/renderD128"; }, while nvenc on the nvidia host also
            # needs /dev/nvidia* added through
            # systemd.services.jellyfin.serviceConfig.DeviceAllow. Without it
            # Jellyfin transcodes in software, which works but is slow.
        };

        # The render node on /dev/dri is owned by the render group; without
        # this membership hardware transcoding fails with a permission error
        # even when the host enables it.
        users.users.jellyfin.extraGroups = [ "video" "render" ];
        # Provides the mesa/VA-API user space drivers that transcoding needs.
        # mkDefault so a host's gpu module wins if it configures this itself.
        hardware.graphics.enable = lib.mkDefault true;
    };
}
