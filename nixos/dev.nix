{ config, pkgs, ... }:
{
    environment.systemPackages = [
        pkgs.obsidian
        pkgs.python312
        pkgs.rustup
        pkgs.cargo
    ];
}
