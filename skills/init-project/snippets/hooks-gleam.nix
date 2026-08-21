# Merge into devenv.nix
{
    git-hooks.hooks = {
        gleam-format = {
            enable = true;
            name = "gleam format";
            entry = "gleam format --check";
            files = "\\.gleam$";
            pass_filenames = false;
        };
    };
}
