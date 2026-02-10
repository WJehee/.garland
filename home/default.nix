{ ... }: {
    imports = [
        ./alacritty.nix
        ./waybar.nix
        ./librewolf.nix
        ./hyprland.nix
        ./hyprlock.nix
        ./hypridle.nix
        ./dunst.nix
        ./nightlight.nix

        ./dev
    ];
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
