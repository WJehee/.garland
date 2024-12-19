{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        # Desktop environment
        hyprpaper
        hyprpicker
        hyprpolkitagent
        hyprshot

        alacritty
        networkmanagerapplet
        blueman
        flavours
        wofi
        syncthing
        qt6.qtwayland
        libsForQt5.qt5.qtwayland
        libsForQt5.qtstyleplugins
        wl-clipboard
        starship
        grimblast
        swappy
        libnotify
        gnupg
        pavucontrol
        pcmanfm
        imv
        brightnessctl
        inetutils
        handlr
        playerctl
        
        # Command line utilities
        ripgrep
        tree
        psmisc
        wget
        zip
        unzip
        unrar
        ffmpeg
        imagemagick
        file
        usbutils
        fzf
        inotify-tools
        systemctl-tui

        # Applications
        firefox
        chromium
        transmission_4-gtk
        spotify
        signal-desktop
        obsidian
        keepassxc
        krita
        gimp
        vlc
        discord
        openvpn
        teams-for-linux
    ];
}
