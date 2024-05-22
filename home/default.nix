{ ... }: {
    imports = [
        ./alacritty
        ./git
        ./nvim
        ./zsh
        ./waybar
        ./firefox.nix
        ./hyprland.nix
    ];
    home = {
        username = "wouter";
        homeDirectory = "/home/wouter";
        stateVersion = "23.05";
        packages = [];
    };
    programs.home-manager.enable = true;
    services.dunst = {
        enable = true;    
        settings = {
            global = {
                monitor = 2;
            };
        };
    };
}
