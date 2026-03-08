{ config, ... }: {
    programs.zsh = {
        enable = true;
        autocd = true;
        shellAliases = {
            la = "ls -A";
            ls = "ls --color";
            ll = "ls -Al";

            nd = "nix develop -c zsh";
        };
        dotDir = "${config.xdg.configHome}/zsh";
        history.path = "${config.xdg.dataHome}/zsh/history";
    };
}
