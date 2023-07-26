{
    description = "nix config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager.url = "github:nix-community/home-manager/release-23.05";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        nix-colors.url = "github:misterio77/nix-colors";
    };

    outputs = { self, nixpkgs, ... }@inputs:
    let
        inherit (self) outputs;
    in
    {
        nixosConfigurations = {
            rusty-nix = nixpkgs.lib.nixosSystem {
                specialArgs = { inherit inputs outputs; };
                modules = [ ./nixos ];
            };
        };
    };
}
