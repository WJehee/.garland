{ pkgs, ... }:
{
    languages.rust = {
        enable = true;
        channel = "nightly";
    };

    packages = with pkgs; [
        cargo-watch
    ];

    git-hooks.hooks = {
        rustfmt.enable = true;
        clippy.enable = true;
    };
}
