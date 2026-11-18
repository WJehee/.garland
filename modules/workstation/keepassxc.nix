# KeePassXC keeps running in the tray: closing the window hides it instead of
# quitting, so the browser extension and the SSH agent integration stay
# connected. The package itself is installed in desktop.nix, the tray widget
# that shows the icon is in noctalia.nix and the LibreWolf side of the browser
# integration is in librewolf.nix.
{
    flake.modules.homeManager.workstation = { config, lib, pkgs, ... }: {
        # Why not programs.keepassxc.settings: it links the whole keepassxc.ini
        # into the nix store, which makes every other setting (browser
        # integration, SSH agent, anything changed in the settings dialog)
        # read-only and makes KeePassXC report a config access error on every
        # start (home-manager issue 8257). Setting only these keys on each
        # activation keeps the files writable; the trade-off is that a value
        # changed in the GUI is put back on the next rebuild.
        #
        # A running KeePassXC only picks the values up after a restart.
        home.activation.keepassxcSettings = let
            # KeePassXC splits its settings over two files: roaming settings in
            # the config dir and machine-local ones in the cache dir. Which
            # file a key belongs to is the Roaming/Local column in
            # src/core/Config.cpp; a key written to the wrong file is ignored.
            roaming = "${config.xdg.configHome}/keepassxc/keepassxc.ini";
            local = "${config.xdg.cacheHome}/keepassxc/keepassxc.ini";
            set = file: section: key: value:
                "run ${lib.getExe pkgs.crudini} --set ${file} ${section} ${key} ${value}";
        in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            run mkdir -p ${dirOf roaming} ${dirOf local}

            ${set roaming "GUI" "ShowTrayIcon" "true"}
            # Both are needed: MinimizeOnClose turns closing into minimizing,
            # MinimizeToTray makes minimizing hide the window into the tray.
            ${set roaming "GUI" "MinimizeOnClose" "true"}
            ${set roaming "GUI" "MinimizeToTray" "true"}

            # The "custom browser configuration location" used to point at
            # ~/.librewolf/native-messaging-hosts so that KeePassXC wrote its
            # manifest there. That manifest is now a home-manager link into
            # the nix store (librewolf.nix), which KeePassXC cannot overwrite,
            # so it must stop trying.
            ${set local "Browser" "UseCustomBrowser" "false"}
        '';
    };
}
