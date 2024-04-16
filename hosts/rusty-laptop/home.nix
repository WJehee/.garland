{ inputs, ... }: {
    imports = [
        inputs.nix-colors.homeManagerModules.default

        ../../home/default.nix
    ];
    colorscheme = inputs.nix-colors.colorSchemes.nord;
    wayland.windowManager.hyprland.settings = {
        monitor = [
            "eDP-1, preferred, auto, 1.175"
        ];
        workspace = [
            "1, monitor:DP-1"
            "2, monitor:DP-1"
            "3, monitor:DP-1"
            "4, monitor:DP-1"
            "5, monitor:DP-1"

            "1, monitor:DP-2"
            "2, monitor:DP-2"
            "3, monitor:DP-2"
            "4, monitor:DP-2"
            "5, monitor:DP-2"
        ];
    };
    xdg.configFile."hypr/hyprpaper.conf".text = ''
        splash = false
        wallpaper = eDP-1, ~/Pictures/wallpaper.jpg
    '';
}
