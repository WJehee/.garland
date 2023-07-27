{ ... }: {
    home.username = "wouter";
    home.homeDirectory = "/home/wouter";
    home.stateVersion = "23.05";
    home.packages = [];
    # colorScheme = nix-colors.colorschemes.nord;

    imports = [
        ./alacritty
        ./git
        ./nvim
        ./zsh
    ];

}
