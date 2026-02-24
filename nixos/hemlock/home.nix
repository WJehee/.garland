{ ... }: {
    imports = [
        ../../home/dev/zsh.nix
        ../../home/dev/git.nix
        ../../home/dev/jujutsu.nix
    ];
    home = {
        username = "admin";
        homeDirectory = "/home/admin";
        stateVersion = "24.11";
        packages = [];
    };
    programs.home-manager.enable = true;
}
