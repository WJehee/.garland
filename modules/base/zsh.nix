{
    flake.modules.nixos.base = { ... }: {
        programs.zsh = {
            enable = true;
            setOptions = [
                "AUTO_CD"
                "COMPLETE_ALIASES"
            ];
        };
        # Convenience for non-zsh consumers and login sessions. Zsh itself does
        # not rely on this: it bootstraps via the ~/.zshenv stub home-manager
        # writes, which sources $ZDOTDIR/.zshenv by absolute path. Do not drop
        # that stub -- /etc/zshenv only exports this on the first shell of a
        # session (__NIXOS_SET_ENVIRONMENT_DONE guard), so a nested zsh that
        # lost ZDOTDIR would fall back to a nonexistent ~/.zshrc.
        environment.sessionVariables.ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    };
}
