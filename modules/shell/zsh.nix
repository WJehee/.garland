{
    flake.modules.homeManager.shell = { config, ... }: {
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
        # home-manager writes a ~/.zshenv that only sources $ZDOTDIR/.zshenv;
        # ZDOTDIR is already exported system wide (modules/base/zsh.nix), so
        # zsh reads the real file directly and the stub can go.
        home.file.".zshenv".enable = false;
    };
}
