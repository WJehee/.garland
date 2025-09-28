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
    home = {
        username = "wouter";
        homeDirectory = "/home/wouter";
        stateVersion = "24.11";
        packages = [];
    };
    programs.home-manager.enable = true;
}
