# Raspberry PI running AdGuard Home (network DNS filter)
{ config, inputs, ... }: {
    flake.modules.nixos."hosts/wormwood" = { lib, ... }: {
        imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-3

            # Default configs
            config.flake.modules.nixos.base
            config.flake.modules.nixos.dev
            config.flake.modules.nixos.server

            # Specific configs
            config.flake.modules.nixos.adguard
            config.flake.modules.nixos.wifi
        ];

        networking.hostName = "wormwood";
        nixpkgs.hostPlatform = "aarch64-linux";
        # DO NOT CHANGE THIS after first install
        # mkForce: the base module pins 24.11 for the older hosts, but a
        # fresh install should start at the release it was installed with
        system.stateVersion = lib.mkForce "26.11";
        nix.settings = {
            trusted-users = [
                "admin"
            ];
            experimental-features = [
                "nix-command"
                "flakes"
            ];
        };
        # Static address so the router can point every client's DNS at it.
        # The router stays the DHCP server: an AdGuard outage then only costs
        # filtering, not the whole network. Wormwood resolves through its own
        # AdGuard (the static profile provides no DNS of its own).
        networking.nameservers = [ "127.0.0.1" ];
        networking.networkmanager.ensureProfiles.profiles.home.ipv4 = {
            method = "manual";
            addresses = "192.168.178.44/24";
            gateway = "192.168.178.1";
        };
        # Passwordless doas for remote deploys (nixos-rebuild --target-host
        # --sudo); mkAfter so this rule sorts after the server module's
        # noPass = false rule, since doas takes the last matching rule
        security.doas.extraRules = lib.mkAfter [{
            users = [ "admin" ];
            keepEnv = true;
            noPass = true;
        }];
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
            # is marked broken for this kernel and wormwood does not use ZFS
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
