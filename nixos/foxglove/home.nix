{ pkgs, ... }: {
    imports = [
        ../../home/default.nix
    ];
    wayland.windowManager.hyprland.settings = {
        monitor = [
            "eDP-1, preferred, auto, 1.2"
        ];
        workspace = [
            "1, monitor:eDP-1"
            "2, monitor:eDP-1"
            "3, monitor:eDP-1"
            "4, monitor:eDP-1"
            "5, monitor:eDP-1"

            "6, monitor:DP-1"
            "7, monitor:DP-1"
            "8, monitor:DP-1"
            "9, monitor:DP-1"
            "10, monitor:DP-1"
        ];
    };
    xdg.configFile."hypr/hyprpaper.conf".text = ''
        splash = false
        preload = ~/.garland/wallpapers/foxglove-landscape.jpg
        wallpaper = eDP-1, ~/.garland/wallpapers/foxglove-landscape.jpg
    '';
}
