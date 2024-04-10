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
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
        # Add any missing dynamic libraries for unpackaged programs
        # here, NOT in environment.systemPackages
    ];
    environment.systemPackages = with pkgs; [
        screenshot

        alacritty
        networkmanagerapplet
        blueman
        flavours
        wofi
        syncthing
        dunst
        qt6.qtwayland
        libsForQt5.qt5.qtwayland
        libsForQt5.qtstyleplugins
        glib

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
        lxqt.lxqt-openssh-askpass
        texlive.combined.scheme-full

        ripgrep
        tree
        psmisc
        wget
        unzip
        unrar
        ffmpeg
        imagemagick
        file
        usbutils

        firefox
        virt-manager
        transmission-gtk
        spotify
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
