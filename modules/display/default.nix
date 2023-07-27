{  pkgs , ... }: {
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
    security.rtkit.enable = true;
    xdg.portal = {
        enable = true;
        extraPortals = [
            pkgs.xdg-desktop-portal-gtk
        ];
    };
    services.xserver = {
        enable = true;
        layout = "us";
        xkbOptions = "eurosign:e,caps:escape";
        videoDrivers = ["modesetting"];

        displayManager = {
            defaultSession = "hyprland";
            lightdm.enable = true;
            autoLogin.enable = true;
            autoLogin.user = "wouter";
        };
    };
    fonts.fonts = with pkgs; [
        hack-font
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        line-awesome
    ];
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };
}
