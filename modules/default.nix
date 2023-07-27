{ inputs, ... }: {
    imports = [
        inputs.nix-colors.homeManagerModules.default
        ./alacritty
        ./git
        ./nvim
        ./zsh
    ];
    home.username = "wouter";
    home.homeDirectory = "/home/wouter";
    home.stateVersion = "23.05";
    home.packages = [];
    colorScheme = inputs.nix-colors.colorSchemes.nord;
}
