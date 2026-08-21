# Merge into devenv.nix
{
    git-hooks.hooks = {
        ruff.enable = true;
        ruff-format.enable = true;
    };
}
