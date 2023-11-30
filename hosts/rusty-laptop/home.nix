{ inputs, ... }: {
    imports = [
        inputs.nix-colors.homeManagerModules.default

        ../../home/default.nix
    ];
    colorscheme = inputs.nix-colors.colorSchemes.nord;
    wayland.windowManager.hyprland.settings = {
        monitor = [
            "eDP-1,preferred,auto,1.25"
        ];
    };
}
