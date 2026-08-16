{ pkgs, ... }:
{
    languages.rust = {
        enable = true;
        channel = "stable";
    };

    packages = with pkgs; [
        cargo-watch
    ];

    git-hooks.hooks = {
        rustfmt.enable = true;
        clippy.enable = true;
    };
}
