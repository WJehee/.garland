{ ... }: {
    imports = [
        ./alacritty
        ./git
        ./nvim
        ./zsh
        ./display
        ./waybar
        ./firefox
    ];
    home = {
        username = "wouter";
        homeDirectory = "/home/wouter";
        stateVersion = "23.05";
        packages = [];
    };
    programs.home-manager.enable = true;
}
