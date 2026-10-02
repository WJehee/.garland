{
    # The *arr automation layer: Prowlarr manages indexers and pushes them to
    # Sonarr (series), Radarr (movies) and Lidarr (music), which send grabs to
    # qbittorrent and move finished downloads into the library. Bazarr fetches
    # subtitles for what Sonarr and Radarr imported.
    #
    # These are admin tools, so unlike Jellyfin they get no public virtual
    # host. They listen on their default ports on all interfaces, and the
    # host firewall only lets that through on tailscale0 (garland's tailscale
    # module trusts that interface). Reach them at http://<host>:<port> over
    # the tailnet: sonarr 8989, radarr 7878, lidarr 8686, prowlarr 9696,
    # bazarr 6767. Each app still enforces its own login.
    #
    # First-run wiring, all through the web UIs: set a root folder per app
    # (/srv/media/tv, /srv/media/movies, /srv/media/music), add qbittorrent as
    # download client at localhost:8080 without credentials, and add the three
    # apps to Prowlarr so it syncs indexers to them.
    flake.modules.nixos.media = { lib, ... }: let
        media = import ./_lib.nix;
        # Everything that creates files or directories inside the library.
        libraryWriters = [ "sonarr" "radarr" "lidarr" "bazarr" ];
    in {
        services = {
            sonarr = {
                enable = true;
                group = media.group;
            };
            radarr = {
                enable = true;
                group = media.group;
            };
            lidarr = {
                enable = true;
                group = media.group;
            };
            bazarr = {
                enable = true;
                group = media.group;
            };
            # Prowlarr only talks to indexers and to the other apps over HTTP
            # and never touches the library, so it keeps the nixpkgs default
            # of running under a dynamic user.
            prowlarr.enable = true;
        };

        # UMask 0002 so directories come out 0775 and files 0664. The nixpkgs
        # units hardcode 0022 (hence mkForce), which makes the series and
        # movie folders Sonarr and Radarr create read-only for the group: then
        # Bazarr cannot save subtitles next to the video and Lidarr cannot
        # write into a folder another app created. The setgid bit on the
        # library handles ownership; this handles the mode.
        systemd.services = lib.genAttrs libraryWriters (_: {
            serviceConfig.UMask = lib.mkForce "0002";
        });
    };
}
