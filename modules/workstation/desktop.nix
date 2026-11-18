{
    flake.modules.nixos.workstation = { pkgs, lib, config, ... }: {
        environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

        services.udisks2.enable = true;
        services.gvfs.enable = true;
        # Keeps ~/.gvfs from appearing. At boot the home-manager activation
        # service runs before the user logs in, so it has neither a session
        # bus nor XDG_RUNTIME_DIR, and home-manager's dconf step then runs
        # `dconf load` under a throwaway `dbus-run-session`. With gvfs
        # enabled, GIO in that dconf process activates a second gvfsd on the
        # throwaway bus, and a gvfsd without XDG_RUNTIME_DIR falls back to the
        # legacy ~/.gvfs for its FUSE mount, which outlives the activation.
        # Forcing GIO's local VFS there means gvfsd is never activated; the
        # session's own gvfsd still mounts at $XDG_RUNTIME_DIR/gvfs.
        systemd.services = lib.mapAttrs' (user: _:
            lib.nameValuePair "home-manager-${user}" {
                environment.GIO_USE_VFS = "local";
            }
        ) config.home-manager.users;

        environment.systemPackages = with pkgs; [
            # Desktop environment
            hyprpaper
            hyprpicker
            hyprpolkitagent
            hyprshot
            networkmanagerapplet
            blueman
            qt6.qtwayland
            qt5.qtwayland
            libsForQt5.qtstyleplugins
            wl-clipboard
            grimblast
            satty
            wofi
            libnotify

            # General applications
            syncthing
            pavucontrol
            pcmanfm
            yazi
            imv
            brightnessctl
            inetutils
            handlr
            playerctl

            # Applications
            signal-desktop
            keepassxc
            vlc
            obsidian

            # Other applications
            krita
            gimp
            blender
            transmission_4-gtk
        ];
    };
}
