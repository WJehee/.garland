{ pkgs, ... }: {
    imports = [
        ../../home/default.nix
    ];
    wayland.windowManager.hyprland.settings = {
        monitor = [
            ", preferred, auto, 1"
            "eDP-1, preferred, auto, 1.2"
            "DP-5, preferred, auto-left, 1, transform, 1"
            "DP-6, preferred, auto-left, 1"
        ];
        workspace = [
            "1, monitor:DP-6"
            "2, monitor:DP-6"
            "3, monitor:DP-6"
            "4, monitor:DP-6"
            "5, monitor:DP-6"

            "6, monitor:DP-5"
            "7, monitor:DP-5"
            "8, monitor:DP-5"
            "9, monitor:DP-5"
            "10, monitor:eDP-1"
        ];
    };
    xdg.configFile."hypr/hyprpaper.conf".text = ''
        splash = false
        preload = ~/.garland/wallpapers/foxglove-landscape.jpg
        wallpaper = eDP-1, ~/.garland/wallpapers/foxglove-landscape.jpg
    '';
}
