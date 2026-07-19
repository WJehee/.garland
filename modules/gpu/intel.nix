{
    flake.modules.nixos."gpu/intel" = { pkgs, ... }: {
        hardware.graphics.extraPackages = with pkgs; [
            intel-compute-runtime
        ];
        boot.initrd.kernelModules = [ "i915" ];
    };
}
