{ ... }: {
    programs.zsh = {
        enable = true;
        dotDir = ".config/zsh";
        shellAliases = {
            la = "ls -A";
            ls = "ls --color";
            ll = "ls -Al";
        };
    };
}
