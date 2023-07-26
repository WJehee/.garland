{ config, pkgs, ... }:
{
    environment.systemPackages = [
        pkgs.python312
        pkgs.rustup
        pkgs.cargo
    ];
}
