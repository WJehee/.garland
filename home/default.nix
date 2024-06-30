{ ... }: {
    imports = [
        ./alacritty.nix
        ./git.nix
        ./zsh.nix
        ./waybar.nix
        ./firefox.nix
        ./hyprland.nix
        ./dunst.nix
        ./clipboard.nix
    ];
    home = {
        username = "wouter";
        homeDirectory = "/home/wouter";
        stateVersion = "23.05";
        packages = [];
    };
    programs.home-manager.enable = true;
}
