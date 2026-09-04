{
    flake.modules.nixos.base = { ... }: {
        programs.zsh = {
            enable = true;
            setOptions = [
                "AUTO_CD"
                "COMPLETE_ALIASES"
            ];
        };
        # Set at login (PAM and /etc/zshenv) so zsh finds its dotfiles under
        # XDG_CONFIG_HOME without a ~/.zshenv bootstrap; see modules/shell/zsh.nix.
        environment.sessionVariables.ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    };
}
