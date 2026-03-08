{ pkgs, ... }: {
    hardware.graphics.extraPackages = with pkgs; [
        intel-ocl
    ];
}
