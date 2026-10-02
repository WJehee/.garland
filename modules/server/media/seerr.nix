{
    # Seerr (formerly Jellyseerr) is the request front end: users log in with
    # their Jellyfin account, search for a movie or series, and the request is
    # forwarded to Radarr or Sonarr. Wire Jellyfin, Radarr and Sonarr into it
    # through its setup wizard on first visit; it needs their API keys, which
    # only exist after those services have started once.
    flake.modules.nixos.media = let
        media = import ./_lib.nix;
    in {
        services.caddy.virtualHosts."requests.${media.domain}".extraConfig = ''
            reverse_proxy http://localhost:5055
        '';

        services.seerr.enable = true;
    };
}
