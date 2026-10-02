{
    # Navidrome streams the music library over the Subsonic API, which most
    # mobile music clients speak. Jellyfin can play music too, but Navidrome
    # handles large libraries, scrobbling and playlists far better, so music
    # gets its own front end.
    flake.modules.nixos.media = let
        media = import ./_lib.nix;
    in {
        services.caddy.virtualHosts."music.${media.domain}".extraConfig = ''
            reverse_proxy http://localhost:4533
        '';

        services.navidrome = {
            enable = true;
            group = media.group;
            # Address defaults to 127.0.0.1 and Port to 4533; only caddy talks
            # to it directly. The music folder is bind-mounted read-only into
            # the unit by the nixpkgs module, so Navidrome can never modify
            # what Lidarr put there.
            settings.MusicFolder = media.dirs.music;
        };
    };
}
