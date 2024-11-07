{ ... }: {
    imports = [
        ./alacritty.nix
        ./git.nix
        ./waybar.nix
        ./firefox.nix
        ./hyprland.nix
        ./dunst.nix
        ./nushell.nix
        ./zsh.nix

        # ./clipboard.nix
    ];
    home = {
        username = "wouter";
        homeDirectory = "/home/wouter";
        stateVersion = "24.11";
        packages = [];
    };
    programs.home-manager.enable = true;
}
