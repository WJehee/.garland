{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        clinfo
    ];
    hardware = {
        graphics = {
            enable = true;
            enable32Bit = true;
            extraPackages = with pkgs; [
                rocmPackages.clr.icd
                intel-ocl
            ];
        };
        amdgpu.opencl.enable = true;
    };
    boot = {
        initrd.kernelModules = [ "amdgpu" ];
        kernelParams = [
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
    programs.hyprland = {
        enable = true;
    };
    services = {
        displayManager = {
            autoLogin = {
                enable = true;
                user = "wouter";
            };
        };
        xserver = {
            enable = true;
            xkb = {
                layout = "us";
                options = "eurosign:e,caps:escape";
            };
            videoDrivers = [ "amdgpu" ];
        };
    };
}
