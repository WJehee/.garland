{ pkgs, ... }: {
    imports = [
        ./hyprland.nix
        ./gtk.nix
        ./qt.nix
    ];
}
