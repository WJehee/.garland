{ ... }: {
    imports = [
	    ../../modules/default.nix
        ../../modules/pentest.nix
    ];
    boot = {
        kernelParams = [ "i915.force_probe=46a6" ];
        initrd.luks.devices.nixos = {
            device = "/dev/disk/by-uuid/38fbea60-655c-4784-92c4-a0c0dac7d6d1";
            preLVM = true;
        };
    };
}
