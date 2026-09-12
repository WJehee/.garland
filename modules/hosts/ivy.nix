# Raspberry PI running Home Assistant
{ config, inputs, ... }: {
    flake.modules.nixos."hosts/ivy" = { lib, ... }: {
        imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-3

            # Default configs
            config.flake.modules.nixos.base
            config.flake.modules.nixos.server

            # Specific configs
            config.flake.modules.nixos.home-assistant
            config.flake.modules.nixos.wifi
            # config.flake.modules.nixos.backup
        ];

        networking.hostName = "ivy";
        nixpkgs.hostPlatform = "aarch64-linux";
        # DO NOT CHANGE THIS after first install
        system.stateVersion = "24.11";
        nix.settings = {
            experimental-features = [
                "nix-command"
                "flakes"
            ];
        };
        # Static address so Home Assistant is always reachable at the same
        # place; the router provides DHCP and DNS for the rest of the network
        networking.networkmanager.ensureProfiles.profiles.home.ipv4 = {
            method = "manual";
            addresses = "192.168.178.43/24";
            gateway = "192.168.178.1";
            dns = "192.168.178.1";
        };
        # Chainload u-boot from the GPU firmware; without this the firmware
        # partition has no kernel= entry at all and the PI does not boot
        # (7 blinks of the ACT led)
        hardware.raspberry-pi.firmware.uboot.enable = true;
        boot = {
            loader = {
                grub.enable = lib.mkForce false;
                generic-extlinux-compatible.enable = true;
            };
            # Grow the root partition to fill the SD card from the initrd on
            # every boot; the sd-image expand-root-partition service is a
            # one-shot that failed on first boot and never retries
            growPartition = true;
            # The SD installer profile enables ZFS, but the ZFS kernel module
            # is marked broken for this kernel and ivy does not use ZFS
            supportedFilesystems.zfs = lib.mkForce false;
        };
        # Root FS as created by the SD image (the sd-image module overrides
        # this when building the image itself)
        fileSystems."/" = {
            device = "/dev/disk/by-label/NIXOS_SD";
            fsType = "ext4";
        };
        environment.variables = {
            SHELL = "zsh";
            EDITOR = "neovim";
        };
    };
}
