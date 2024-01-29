{ ... }: {
    xdg.configFile."hypr/hyprpaper.conf".text = ''
        splash = false
        preload = ~/Pictures/wallpaper.jpg
        preload = ~/Pictures/wallpaper2.jpg
        wallpaper = DP-2, ~/Pictures/wallpaper.jpg
        wallpaper = DP-3, ~/Pictures/wallpaper2.jpg
        wallpaper = HDMI-A-1, ~/Pictures/wallpaper.jpg
    '';
}
