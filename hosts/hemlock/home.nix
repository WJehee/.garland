{ ... }: {
    imports = [
        ../../modules/home/dev/zsh.nix
        ../../modules/home/dev/git.nix
        ../../modules/home/dev/jujutsu.nix
    ];
    home = {
        username = "admin";
        homeDirectory = "/home/admin";
        stateVersion = "26.11";
        packages = [];
    };
    programs.home-manager.enable = true;
}
