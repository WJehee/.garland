{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        # Desktop environment
        hyprpaper
        hyprpicker
        hyprpolkitagent
        hyprshot
    
        # General applications
        networkmanagerapplet
        blueman
        flavours
        wofi
        syncthing
        qt6.qtwayland
        libsForQt5.qt5.qtwayland
        libsForQt5.qtstyleplugins
        wl-clipboard
        grimblast
        swappy
        libnotify
        gnupg
        pavucontrol
        pcmanfm
        yazi
        imv
        brightnessctl
        inetutils
        handlr
        playerctl
       
        # Additional tools
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
        nomino
        zenith
        dig
        jq
        fd
        bat
        eza
        zellij
        cool-retro-term

        # Applications
        transmission_4-gtk
        signal-desktop
        obsidian
        keepassxc
        krita
        gimp
        vlc
        blender

    ];
}
