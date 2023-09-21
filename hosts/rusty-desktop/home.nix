{ inputs, ... }: {
    imports = [
        inputs.nix-colors.homeManagerModules.default

        ../../home/default.nix
    ];
    colorscheme = inputs.nix-colors.colorSchemes.nord;
}
