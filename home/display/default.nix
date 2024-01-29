{ pkgs, ... }: {
    imports = [
        ./hyprland.nix
        ./hyprpaper.nix
        ./gtk.nix
        ./qt.nix
    ];
}
