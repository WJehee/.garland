{
    description = "My NixOS config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        disko = {
            url = "github:nix-community/disko";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        stylix = {
            url = "github:danth/stylix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixvim = {
            url = "github:nix-community/nixvim";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixos-hardware = {
            url = "github:nixos/nixos-hardware/master";
        };

        loodsenboekje.url = "github:wjehee/loodsenboekje.com";
    };

    outputs = { flake-parts, ... }@inputs:
        flake-parts.lib.mkFlake { inherit inputs; } {
            systems = [
                "x86_64-linux"
                "aarch64-linux"
            ];
            imports = [
                ./nixos
            ];
            # flake = {
            #     diskoConfigurations.disko = import ./nixos/disk-config.nix;
            #     templates = import ./templates;
            #     nvim = inputs.nixvim.legacyPackages.x86_64-linux.makeNixvimWithModule {
            #         module = import ../modules/dev/nvim.nix;
            #         extraSpecialArgs.inputs = inputs;
            #     };
            # };
            # perSystem = { config, pkgs, ... }: {
            #     # Recommended: move all package definitions here.
            #     # e.g. (assuming you have a nixpkgs input)
            #     # packages.foo = pkgs.callPackage ./foo/package.nix { };
            #     # packages.bar = pkgs.callPackage ./bar/package.nix {
            #     #   foo = config.packages.foo;
            #     # };
            # };
        };
}
