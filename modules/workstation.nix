{ pkgs, ... }: {
    imports = [
        ./user.nix
        ./chromium.nix
        ./bluetooth.nix
        ./stylix.nix
        ./geoclue.nix
        ./wallet.nix
        ./virtualization.nix

        ./dev
        ./media
        ./hacking
    ];

    programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-gtk2;
    };

    environment.systemPackages = with pkgs; [
        # Desktop environment
        hyprpaper
        hyprpicker
        hyprpolkitagent
        hyprshot
        networkmanagerapplet
        blueman
        qt6.qtwayland
        libsForQt5.qt5.qtwayland
        libsForQt5.qtstyleplugins
        wl-clipboard
        grimblast
        swappy
        wofi
        libnotify
    
        # General applications
        syncthing
        gnupg
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
}
