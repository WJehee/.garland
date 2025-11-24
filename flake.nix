{
    description = "My NixOS config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

    outputs = { nixpkgs, home-manager, ... }@inputs: let
        mkSystem = system: hostname:
            inputs.nixpkgs.lib.nixosSystem {
                system = system;
                specialArgs = { inherit inputs hostname; };
                modules = [
                    { networking.hostName = hostname; }
                    ./nixos/${hostname}/configuration.nix
                    ./nixos/${hostname}/hardware-configuration.nix

                    inputs.disko.nixosModules.disko
                    inputs.stylix.nixosModules.stylix
                    inputs.nixvim.nixosModules.nixvim

                    inputs.loodsenboekje.nixosModules.loodsenboekje

                    home-manager.nixosModules.home-manager {
                        home-manager = if builtins.pathExists ./nixos/${hostname}/home.nix
                            then {
                                extraSpecialArgs = { inherit inputs; };
                                users.wouter = ./nixos/${hostname}/home.nix;
                                useUserPackages = true;
                            } else {};
                    }
                ];
            };
    in {
        nixosConfigurations = {
            foxglove = mkSystem "x86_64-linux" "foxglove";
            hemlock = mkSystem "x86_64-linux" "hemlock";
            wisteria = mkSystem "x86_64-linux" "wisteria"; 
            ivy = inputs.nixpkgs.lib.nixosSystem {
                system = "aarch64-linux";
                modules = [
                    inputs.nixos-hardware.nixosModules.raspberry-pi-3
                    ./nixos/ivy/configuration.nix
                ];
            };
        };
        diskoConfigurations.disko = import ./nixos/disk-config.nix;
        templates = import ./templates;
        nvim = inputs.nixvim.legacyPackages.x86_64-linux.makeNixvimWithModule {
            module = import ../modules/dev/nvim.nix;
            extraSpecialArgs.inputs = inputs;
        };
    };
}
