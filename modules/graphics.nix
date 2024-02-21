{ pkgs, ... }: {
    hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [
            mesa.drivers
            amdvlk
        ];
    };
    xdg.portal = {
        enable = true;
        extraPortals = [
            pkgs.xdg-desktop-portal-gtk
            pkgs.xdg-desktop-portal-hyprland
        ];
    };
    services.xserver = {
        enable = true;
        xkb = {
            layout = "us";
            options = "eurosign:e,caps:escape";
        };
        videoDrivers = [ "modesetting" ];

        displayManager = {
            defaultSession = "hyprland";
            lightdm.enable = true;
            autoLogin.enable = true;
            autoLogin.user = "wouter";
        };
    };
}
