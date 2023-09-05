{ inputs, ... }: {
    imports = [
        inputs.nix-colors.homeManagerModules.default

        ../../modules/default.nix
    ];
    colorscheme = inputs.nix-colors.colorSchemes.nord;
    boot.initrd.luks.devices.nixos.device = "/dev/disk/by-uuid/38fbea60-655c-4784-92c4-a0c0dac7d6d1";
}
