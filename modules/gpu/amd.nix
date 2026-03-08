{ pkgs, ... }: {
    hardware = {
        amdgpu.opencl.enable = true;
        graphics.extraPackages = with pkgs; [
            rocmPackages.clr.icd
        ];
    };
    boot = {
        initrd.kernelModules = [ "amdgpu" ];
        # Force amdgpu driver for older Southern Island / Coastal Island cards
        kernelParams = [
            "radeon.si_support=0"
            "radeon.cik_support=0"
            "amdgpu.si_support=1"
            "amdgpu.cik_support=1"
        ];
    };
    services.xserver.videoDrivers = [ "amdgpu" ];
}
