{ ... }: {
    imports = [
        ../../modules
        ../../modules/hacking
        ../../modules/dev/android.nix
        ../../disk/luks-lvm.nix
    ];
    boot = {
        kernelParams = [ "i915.force_probe=46a6" ];
    };
}
