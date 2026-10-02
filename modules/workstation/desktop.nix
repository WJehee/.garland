{
    flake.modules.nixos.workstation = { pkgs, ... }: {
        environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

        services.udisks2.enable = true;
        services.gvfs.enable = true;

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
            # TODO: re-enable handlr once its nixpkgs tests pass again with
            # shared-mime-info >= 2.5, which renamed shell scripts from
            # application/x-shellscript to text/x-shellscript. handlr-regex,
            # the maintained fork, fails the same way and tracks it in
            # https://github.com/Anomalocaridid/handlr-regex/issues/139.
            # handlr
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
