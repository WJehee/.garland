{ pkgs, ... }: {
    imports = [
        ./user.nix
        ./chromium.nix
        ./bluetooth.nix
        ./stylix.nix
        ./geoclue.nix
        ./wallet.nix
        ./pipewire.nix
        ./syncthing.nix
        ./graphics.nix
    ];

    environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

    # Auto-mounting of removable media (USB sticks, SD cards, etc.).
    # udisks2 is the privileged mount backend; gvfs lets pcmanfm/yazi
    # browse and mount. The udiskie daemon that triggers mounts on insert
    # runs as a home-manager systemd user service (see hyprland.nix).
    services.udisks2.enable = true;
    services.gvfs.enable = true;

    programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-gtk2;
    };

    environment.systemPackages = with pkgs; [
        # Desktop environment
        hyprpaper
        hyprpicker
        hyprpolkitagent
        hyprshot
        networkmanagerapplet
        blueman
        qt6.qtwayland
        qt5.qtwayland
        libsForQt5.qtstyleplugins
        wl-clipboard
        grimblast
        swappy
        wofi
        libnotify
    
        # General applications
        syncthing
        gnupg
        pavucontrol
        pcmanfm
        yazi
        imv
        brightnessctl
        inetutils
        handlr
        playerctl

        # Applications
        signal-desktop
        keepassxc
        vlc
        obsidian

        # Other applications
        krita
        gimp
        blender
        transmission_4-gtk
    ];
}
