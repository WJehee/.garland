{ ... }: {
    imports = [
        ../../modules/disk/luks-lvm.nix

        ../../modules/core
        ../../modules/core/workstation.nix
    ];

    boot = {
        kernelParams = [ "i915.force_probe=46a6" ];
    };
}
