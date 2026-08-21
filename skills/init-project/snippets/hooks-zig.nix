# Merge into devenv.nix
{
    git-hooks.hooks = {
        zig-fmt = {
            enable = true;
            name = "zig fmt";
            entry = "zig fmt --check";
            files = "\\.zig$";
        };
    };
}
