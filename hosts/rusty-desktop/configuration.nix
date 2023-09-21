{ inputs, ... }: {
    imports = [
	    ../../modules/system/default.nix
    ];
    boot.initrd.luks.devices.nixos = {
	device = "/dev/disk/by-uuid/79f8374d-c878-442c-acd0-88f474dda0d6";
	preLVM = true;
    };
}
# lsblk -f | grep sda2 | awk '{print $4 }'
