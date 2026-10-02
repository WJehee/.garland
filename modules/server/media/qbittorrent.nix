{
    # qbittorrent is the download client behind Sonarr, Radarr and Lidarr.
    #
    # In the context of a headless client whose settings must survive
    # rebuilds, facing the choice between a declarative config and one edited
    # in the web UI, we chose serverConfig to keep paths and auth in nix,
    # accepting that the nixpkgs unit reinstalls the whole qBittorrent.conf on
    # every start, so preference changes made in the web UI are lost on the
    # next restart. Torrent state and categories live in other files and do
    # persist. Put any lasting preference here instead.
    flake.modules.nixos.media = let
        media = import ./_lib.nix;
    in {
        services.qbittorrent = {
            enable = true;
            group = media.group;
            webuiPort = 8080;
            serverConfig = {
                # Required for the headless build to start at all.
                LegalNotice.Accepted = true;
                Preferences.WebUI = {
                    # No password: the firewall already restricts port 8080 to
                    # the tailnet, and the arr apps connect from localhost.
                    # Trusting those two ranges outright avoids storing a
                    # PBKDF2 hash in the world-readable nix store and lets the
                    # arr download-client entries stay credential-less.
                    # 100.64.0.0/10 is the CGNAT range tailscale assigns from.
                    LocalHostAuth = false;
                    AuthSubnetWhitelistEnabled = true;
                    AuthSubnetWhitelist = "100.64.0.0/10";
                };
                BitTorrent.Session = {
                    DefaultSavePath = media.dirs.downloads;
                    # Incomplete downloads in their own directory so the arr
                    # apps never try to import a half-written file.
                    TempPathEnabled = true;
                    TempPath = "${media.dirs.downloads}/incomplete";
                    # Automatic torrent management: each torrent lands in
                    # <DefaultSavePath>/<category>, and the arr apps tag their
                    # grabs with a category, which keeps tv, movies and music
                    # downloads apart without configuring paths per app.
                    DisableAutoTMMByDefault = false;
                };
            };
        };

        # Group-writable downloads, so the arr apps can rename and hardlink
        # them into the library. See arr.nix for the full reasoning.
        systemd.services.qbittorrent.serviceConfig.UMask = "0002";
    };
}
