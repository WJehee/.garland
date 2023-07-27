{ inputs, pkgs, ... }: {
    imports = [
        # inputs.hyprland.homeManagerModules.default
    ];
    environment.systemPackages = with pkgs; [
        qt6.qtwayland
        libsForQt5.qt5.qtwayland
        wl-clipboard
        cliphist
        grim
        hyprpaper
        libnotify
        swayidle
        swaylock-effects
    ];
    programs.hyprland.enable = true;
    programs.waybar.enable = true;
    # wayland.windowManager.hyprland = {
    #     enable = true;
    # };
}
