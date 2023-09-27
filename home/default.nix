{ inputs, ... }: {
    imports = [
        ./alacritty
        ./git
        ./nvim
        ./zsh
        ./display
        ./waybar
        ./firefox
    ];
    home.username = "wouter";
    home.homeDirectory = "/home/wouter";
    home.stateVersion = "23.05";
    home.packages = [];

    # Temporary fix for build issues
    manual.manpages.enable = false;

    programs.home-manager.enable = true;
    services.gpg-agent.enable = true;
}
