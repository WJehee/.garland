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
