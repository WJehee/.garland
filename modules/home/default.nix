{ lib, vars, ... }: {
    imports = [
        ./stylix.nix
        ./alacritty.nix
        ./waybar.nix
        ./librewolf.nix
        ./dunst.nix
        ./nightlight.nix

        ./dev
    ]
    ++ lib.optionals (vars.garland.windowManager == "hyprland") [ ./hyprland ];

    dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
    };
    home = {
        username = "wouter";
        homeDirectory = "/home/wouter";
        stateVersion = "24.11";
        packages = [];
    };
    programs.home-manager.enable = true;
}
