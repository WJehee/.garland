{
    flake.modules.nixos."gpu/nvidia" = {
        hardware.graphics.enable = true;
        hardware.nvidia = {
            # Open kernel module, recommended for Turing (RTX 20xx) and newer
            open = true;
            # Required for wayland/hyprland
            modesetting.enable = true;
        };
        services.xserver.videoDrivers = [ "nvidia" ];
    };
}
