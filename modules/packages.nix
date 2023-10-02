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
    environment.systemPackages = with pkgs; [
        screenshot
        python3Full
        rustup
        cargo
        rust-analyzer
        clippy
        rustfmt
        trunk
        cargo-leptos
        gcc
        ripgrep
        signal-desktop
        obsidian
        flavours
        alacritty
        firefox
        wofi
        syncthing
        keepassxc
        dunst
        bspwm
        git
        qt6.qtwayland
        libsForQt5.qt5.qtwayland
        libsForQt5.qtstyleplugins
        wl-clipboard
        cliphist
        sway-contrib.grimshot
        hyprpaper
        libnotify
        swayidle
        swaylock-effects
        pavucontrol
        vlc
        psmisc
        networkmanagerapplet
        spotify
        wget
        unzip
        ffmpeg
        imagemagick
        gnupg
        krita
        gimp
        tree
        zola
        nodejs
        virt-manager
        docker
        docker-compose
        pcmanfm
        unrar
    ];
}
