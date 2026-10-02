# Shared constants for the media stack. The underscore prefix keeps import-tree
# from loading this as a module; each sibling file does `import ./_lib.nix`.
rec {
    # Every service that reads or writes the library runs with this as its
    # primary group. The library directories are setgid, so files created by
    # one service are owned by this group and writable by the others.
    group = "media";

    # One tree on one filesystem on purpose: Sonarr, Radarr and Lidarr hardlink
    # finished downloads into the library, which only works within a single
    # filesystem, and a second copy of every file would otherwise double the
    # disk usage. Under /srv rather than /home because the service units run
    # with ProtectHome, which hides /home from them entirely.
    root = "/srv/media";
    dirs = {
        movies = "${root}/movies";
        tv = "${root}/tv";
        music = "${root}/music";
        downloads = "${root}/downloads";
    };

    # Public entry points are caddy virtual hosts under this domain, like the
    # other services in garland.
    domain = "wouterjehee.com";
}
