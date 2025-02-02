{ ... }: {
    imports = [
	    ../../modules
        ../../modules/hacking
        # ../../modules/media/gaming.nix
    ];
    boot = {
        initrd.luks.devices.nixos = {
            device = "/dev/disk/by-uuid/79f8374d-c878-442c-acd0-88f474dda0d6";
            preLVM = true;
        };
        # Old graphics card support
        kernelParams = [
            "radeon.si_support=0"
            "radeon.cik_support=0"
            "amdgpu.si_support=1"
            "amdgpu.cik_support=1"
        ];
    };
}
