{ ... }: {
    imports = [
        ../../modules/default.nix
        ../../modules/hacking.nix
        ../disk-config.nix
    ];
    boot = {
        kernelParams = [ "i915.force_probe=46a6" ];
    };
}
