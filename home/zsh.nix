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
        dotDir = ".config/zsh";
        history.path = "${config.xdg.dataHome}/zsh/history";
        initExtra = ''
            eval "$(zoxide init zsh --cmd cd)"
        '';
    };
}
