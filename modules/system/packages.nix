{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        pkgs.python312
            pkgs.rustup
            pkgs.cargo
            gcc
            ripgrep
            signal-desktop
            obsidian
            flavours
            alacritty
            firefox
            wofi
            syncthing
            keepassxc
            dunst
            bspwm
            git
            docker
    ];
}
