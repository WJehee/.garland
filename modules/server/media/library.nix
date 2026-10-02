{
    # The media library shared by every service in this directory: the group
    # they all run as and the directory tree they all point at.
    flake.modules.nixos.media = { lib, ... }: let
        media = import ./_lib.nix;
    in {
        users.groups.${media.group} = {};

        # Mode 2775: the setgid bit makes new files and directories inherit the
        # media group regardless of which service created them, and group write
        # lets the arr apps rename and delete files that qbittorrent or bazarr
        # created. Root owns the directories so no single service can chown the
        # tree away from the others. The navidrome module declares its own
        # tmpfiles rule for the music folder; that rule is marked "only if
        # missing" and this file sorts before it, so systemd-tmpfiles logs a
        # duplicate-line warning for that path and keeps this rule. Harmless.
        systemd.tmpfiles.settings."10-media" = lib.mapAttrs'
            (_: dir: lib.nameValuePair dir {
                d = {
                    mode = "2775";
                    user = "root";
                    group = media.group;
                };
            })
            (media.dirs // { root = media.root; });
    };
}
