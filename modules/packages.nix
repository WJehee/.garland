{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        hyprpaper
        hyprpicker
        hyprpolkitagent
        hyprshot

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
        # TODO: include again if fixed
        # asciidoc-full-with-plugins
        # asciidoctor-with-extensions
        
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

        transmission_4-gtk
        signal-desktop
        obsidian
        keepassxc
        krita
        gimp
        vlc
        discord
        openvpn
        # remmina
    ];
}
