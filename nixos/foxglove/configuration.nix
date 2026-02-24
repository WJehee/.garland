{ ... }: {
    imports = [
        ../../disk/luks-lvm.nix

        ../../modules
        ../../modules/workstation.nix
    ];
    boot = {
        kernelParams = [ "i915.force_probe=46a6" ];
    };
}
