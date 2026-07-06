{ lib, ... }: {
    imports = [
        # Default configs
        ../../modules/core
        ../../modules/dev
        ../../modules/server/headless.nix

        # Specific configs
        ../../modules/core/home-assistant.nix
    ];
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
}
