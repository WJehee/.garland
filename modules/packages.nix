{ pkgs, ... }:
let
    screenshot = pkgs.writeShellScriptBin "screenshot" ''
OPTIONS="copy\nsave"
CHOICE=$(echo -e $OPTIONS | wofi -d) || exit 0
case $CHOICE in
    copy) grimshot copy area ;;
    save)
        FILENAME=$(grimshot save area)
        mogrify -format webp $FILENAME
        rm $FILENAME ;;
esac
    '';
    # Hacky workaround for making QT theme work
    my-opensnitch = pkgs.writeShellScriptBin "my-opensnitch" ''
source /home/wouter/.zshenv
opensnitch-ui
    '';
in {
    environment.systemPackages = with pkgs; [
        # Custom packages
        screenshot
        my-opensnitch

        # Required
        alacritty
        networkmanagerapplet
        flavours
        wofi
        syncthing
        dunst
        bspwm
        qt6.qtwayland
        libsForQt5.qt5.qtwayland
        libsForQt5.qtstyleplugins

        wl-clipboard
        wl-clip-persist
        sway-contrib.grimshot
        hyprpaper
        hyprpicker
        libnotify
        swayidle
        swaylock-effects
        gnupg
        pavucontrol
        pcmanfm
        imv
        inetutils
        handlr

        # Command line
        ripgrep
        tree
        psmisc
        wget
        unzip
        unrar
        ffmpeg
        imagemagick
        just

        # Dev tools
        python3Full
        python311Packages.jedi-language-server
        rustup
        clippy
        rustfmt
        cargo
        cargo-generate
        cargo-watch
        gcc
        git
        nodejs
        docker
        docker-compose
        tmux
        nil
        elixir

        # Programs
        virt-manager
        transmission-gtk
        spotify
        firefox
        signal-desktop
        obsidian
        keepassxc
        krita
        gimp
        vlc
        opensnitch-ui

        # VPN
        openvpn
    ];
}
