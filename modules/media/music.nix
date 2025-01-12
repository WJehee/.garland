{ pkgs, inputs, ... }: {
    environment.systemPackages = with pkgs; [
        spotify
    ];
    # programs.spicetify = let
    #     spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    # in {
    #     enable = true;
    #     enabledExtensions = with spicePkgs.extensions; [
    #         adblock
    #         shuffle
    #         betterGenres
    #     ];
    #     theme = spicePkgs.themes.nord;
    #     colorScheme = "nord";
    # };
}
