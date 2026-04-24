{ ... }: {
    imports = [
        ../../modules/disk/luks-lvm.nix

        ../../modules/core
        ../../modules/core/workstation.nix
        ../../modules/hacking
    ];

    boot = {
        kernelParams = [ "i915.force_probe=46a6" ];
    };
}
