{ pkgs, ... }:
let
    screenshot = pkgs.writeShellScriptBin "screenshot" ''
        grimblast --freeze copysave area /tmp/screenshot.png && swappy -f /tmp/screenshot.png
        rm /tmp/screenshot.png
    '';
    ex = pkgs.writeShellScriptBin "ex" ''
        if [ -f $1 ] ; then
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
in {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
        libGL
    ];
    environment.systemPackages = with pkgs; [
        screenshot
        ex

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
        teams-for-linux
        lxqt.lxqt-openssh-askpass
        texlive.combined.scheme-full

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

        firefox
        virt-manager
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
    ];
}
