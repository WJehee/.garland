{ pkgs, ... }:
let
    screenshot = pkgs.writeShellScriptBin "screenshot" ''
        grimblast --freeze copysave area /tmp/screenshot.png && swappy -f /tmp/screenshot.png
        rm /tmp/screenshot.png
    '';
    ex = pkgs.writeShellScriptBin "ex" ''
        if [ -n $1 ] ; then
          case $1 in
            *.tar.bz2)   tar xjf $1   ;;
            *.tar.gz)    tar xzf $1   ;;
            *.bz2)       bunzip2 $1   ;;
            *.rar)       unrar x $1   ;;
            *.gz)        gunzip $1    ;;
            *.tar)       tar xf $1    ;;
            *.tbz2)      tar xjf $1   ;;
            *.tgz)       tar xzf $1   ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1;;
            *.7z)        7z x $1      ;;
            *.deb)       ar x $1      ;;
            *.tar.xz)    tar xf $1    ;;
            *.tar.zst)   unzstd $1    ;;
            *.xz)        unxz $1      ;;
            *)           echo "'$1' cannot be extracted via ex" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
    '';
    flake-template = pkgs.writeShellScriptBin "flake-template" ''
        if [ -n $1 ] ; then
            nix flake init -t "github:wjehee/.dotfiles-nix#$1"
        else
            echo "must provide an argument"
        fi
    '';
in {
    environment.systemPackages = with pkgs; [
        # Custom packages
        screenshot
        ex
        flake-template

        # Desktop environment
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
        lxqt.lxqt-openssh-askpass
        doas-sudo-shim
        
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
