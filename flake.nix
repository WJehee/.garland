{
    description = "My NixOS config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        home-manager.url = "github:nix-community/home-manager";
        disko.url = "github:nix-community/disko";
        stylix.url = "github:danth/stylix";
        nixvim.url = "github:nix-community/nixvim";
        nixos-hardware.url = "github:nixos/nixos-hardware/master";
        
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
            flake = {
                templates = import ./templates;
                nvim = inputs.nixvim.legacyPackages.x86_64-linux.makeNixvimWithModule {
                    module = import ../modules/dev/nvim.nix;
                    extraSpecialArgs.inputs = inputs;
                };
            };
        };
}
