# Raspberry PI 3 running Kodi (modules/features/kodi.nix), a
# NixOS take on OSMC/LibreELEC. Built as an SD image with
# `just build-sd belladonna`, like ivy and wormwood.

{ config, inputs, ... }: {
    flake.modules.nixos."hosts/belladonna" = { lib, ... }: {
        imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-3

            config.flake.modules.nixos.base
            config.flake.modules.nixos.server

            config.flake.modules.nixos.kodi
            config.flake.modules.nixos.wifi
        ];

        networking.hostName = "belladonna";
        nixpkgs.hostPlatform = "aarch64-linux";
        # DO NOT CHANGE THIS after first install
        system.stateVersion = lib.mkForce "26.11";
        nix.settings = {
            experimental-features = [
                "nix-command"
                "flakes"
            ];
        };
        # Static address so remote apps and ssh find the box at the same
        # place; the router provides DHCP and DNS for the rest of the network
        networking.networkmanager.ensureProfiles.profiles.home.ipv4 = {
            method = "manual";
            addresses = "192.168.178.45/24";
            gateway = "192.168.178.1";
            dns = "192.168.178.1";
        };
        hardware.raspberry-pi.firmware.uboot.enable = true;
        boot = {
            loader = {
                grub.enable = lib.mkForce false;
                generic-extlinux-compatible.enable = true;
            };
            growPartition = true;
            supportedFilesystems.zfs = lib.mkForce false;
        };
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
