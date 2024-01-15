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
in {
    imports = [
        ./dev.nix
    ];
    environment.systemPackages = with pkgs; [
        # Custom packages
        screenshot

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
        ledger-live-desktop
        teams-for-linux
        xwayland
        xwaylandvideobridge

        # Command line
        ripgrep
        tree
        psmisc
        wget
        unzip
        unrar
        ffmpeg
        imagemagick
        file

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
        discord
        openvpn
    ];
}
