{ pkgs, ... }: {
    hardware.opengl = {
        enable = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [
            mesa.drivers
            amdvlk
        ];
    };
    boot = {
        # initrd.kernelModules = [ "amdgpu" ];
        kernelParams = [
            "radeon.cik_support=0"
            "amdgpu.cik_support=1"
            "quiet"
            "splash"
        ];
    };

    xdg.portal = {
        enable = true;
        extraPortals = [
            pkgs.xdg-desktop-portal-gtk
            pkgs.xdg-desktop-portal-hyprland
        ];
    };
    programs.hyprland.enable = true;
    services.displayManager = {
        defaultSession = "hyprland";
        autoLogin = {
            enable = true;
            user = "wouter";
        };
    };
    services.xserver = {
        enable = true;
        xkb = {
            layout = "us";
            options = "eurosign:e,caps:escape";
        };
        # videoDrivers = [ "modesetting" ];
        videoDrivers = [ "amdgpu" ];
    };
}
