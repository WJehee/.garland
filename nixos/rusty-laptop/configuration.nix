{ ... }: {
    imports = [
        ../../modules/default.nix
        ../../modules/pentest.nix
        ../disk-config.nix
    ];
    boot = {
        kernelParams = [ "i915.force_probe=46a6" ];
    };
}
