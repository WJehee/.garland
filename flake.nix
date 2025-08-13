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

        loodsenboekje.url = "github:wjehee/loodsenboekje.com";
    };

    outputs = { nixpkgs, home-manager, ... }@inputs: let
        systems = [ "x86_64-linux" "aarch64-linux" ];
        forAllSystems = nixpkgs.lib.genAttrs systems;

        mkSystem = system: hostname:
            inputs.nixpkgs.lib.nixosSystem {
                system = system;
                specialArgs = { inherit inputs; };
                modules = [
                    { networking.hostName = hostname; }
                    ./nixos/${hostname}/configuration.nix
                    ./nixos/${hostname}/hardware-configuration.nix

                    inputs.stylix.nixosModules.stylix
                    inputs.nixvim.nixosModules.nixvim
                    inputs.disko.nixosModules.disko
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
        };
        diskoConfigurations.disko = import ./nixos/disk-config.nix;
        templates = import ./templates;
        nvim = inputs.nixvim.legacyPackages.x86_64-linux.makeNixvimWithModule {
            module = import ../modules/dev/nvim.nix;
            extraSpecialArgs.inputs = inputs;
        };
    };
}

