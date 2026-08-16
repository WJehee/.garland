{ pkgs, ... }:
{
    languages.zig.enable = true;

    packages = with pkgs; [
        zig-shell-completions
    ];
}
