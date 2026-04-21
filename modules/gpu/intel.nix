{ pkgs, ... }: {
    hardware.graphics.extraPackages = with pkgs; [
        intel-ocl
    ];
    boot.initrd.kernelModules = [ "i915" ];
}
