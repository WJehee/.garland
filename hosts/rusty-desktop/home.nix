{ inputs, ... }: {
    imports = [
        inputs.nix-colors.homeManagerModules.default

        ../../modules/default.nix
    ];
    colorscheme = inputs.nix-colors.colorSchemes.nord;
}
