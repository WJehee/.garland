{ pkgs, ... }: {
    imports = [
        ../../home/default.nix
    ];
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";
    wayland.windowManager.hyprland.settings = {
        monitor = [
            "DP-2,preferred,auto,1"
            "DP-3,preferred,auto,1,transform,1"
            "HDMI-A-1,preferred,auto,1"
        ];
        workspace = [
            "1, monitor:DP-2, default:true"
            "2, monitor:DP-2"
            "3, monitor:DP-2"
            "4, monitor:DP-2"
            "5, monitor:DP-2"

            "6, monitor:DP-3, layoutopt:orientation:top"
            "7, monitor:DP-3, layoutopt:orientation:top"
            "8, monitor:DP-3, layoutopt:orientation:top"

            "9, monitor:HDMI-A-1"
            "10, monitor:HDMI-A-1"
        ];
    };
    xdg.configFile."hypr/hyprpaper.conf".text = ''
        splash = false
        preload = ~/Pictures/wallpaper.jpg
        preload = ~/Pictures/wallpaper2.jpg
        wallpaper = DP-2, ~/Pictures/wallpaper.jpg
        wallpaper = DP-3, ~/Pictures/wallpaper2.jpg
        wallpaper = HDMI-A-1, ~/Pictures/wallpaper.jpg
    '';
}
