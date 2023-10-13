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
        python311Packages.jedi-language-server
        rustup
        clippy
        rustfmt
        cargo
        cargo-generate
        cargo-watch
        gcc
        git
        zola
        nodejs
        docker
        docker-compose
        tmux
        nil

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
        virt-manager
        pcmanfm
        unrar
        transmission-gtk
    ];
}
