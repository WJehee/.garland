# Raspberry PI running Home Assistant
{ config, inputs, ... }: {
    flake.modules.nixos."hosts/ivy" = { lib, ... }: {
        imports = [
            inputs.nixos-hardware.nixosModules.raspberry-pi-3

            # Default configs
            config.flake.modules.nixos.base
            config.flake.modules.nixos.dev
            config.flake.modules.nixos.server

            # Specific configs
            config.flake.modules.nixos.home-assistant
        ];

        networking.hostName = "ivy";
        nixpkgs.hostPlatform = "aarch64-linux";
        # DO NOT CHANGE THIS after first install
        system.stateVersion = "24.11";
        nix.settings = {
            trusted-users = [
                "admin"
            ];
            experimental-features = [
                "nix-command"
                "flakes"
            ];
        };
        boot = {
            loader = {
                grub.enable = lib.mkForce false;
                generic-extlinux-compatible.enable = true;
            };
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
