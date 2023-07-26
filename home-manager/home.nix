{ inputs, outputs, lib, config, pkgs, ... }:
{
    imports = [
        inputs.nix-colors.homeManagerModules.default
    ];
    home.username = "wouter";
    home.homeDirectory = "/home/wouter";
    home.stateVersion = "23.05";
    home.packages = [];

    colorScheme = inputs.nix-colors.colorschemes.nord;

    programs.alacritty = {
        enable = true;
        settings.window.opacity = 0.85;
    };
    programs.git = {
        enable = true;
        userName = "Wouter Jehee";
        userEmail = "wouterjehee@tutanota.com";
        ignores = [
            ".env"
                "_pycache_/"
        ];
    };
    programs.zsh = {
        enable = true;
        dotDir = ".config/zsh";
        shellAliases = {
            la = "ls -A";
            ls = "ls --color";
            ll = "ls -Al";
        };
    };
    programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
    };
}
