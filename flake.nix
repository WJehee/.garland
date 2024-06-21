{
    description = "My NixOS config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
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
        disko = {
            url = "github:nix-community/disko";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        loodsenboekje.url = "github:wjehee/loodsenboekje.com";
    };

    outputs = { nixpkgs, home-manager, ... }@inputs:
    let 
        mkSystem = pkgs: system: hostname: extra_modules:
            pkgs.lib.nixosSystem {
                system = system;
                specialArgs = { inherit inputs; };
                modules = extra_modules ++ [
                    { networking.hostName = hostname; }
                    (./. + "/hosts/${hostname}/hardware-configuration.nix")
                    (./. + "/hosts/${hostname}/configuration.nix")

                    home-manager.nixosModules.home-manager {
                        home-manager = if builtins.pathExists (./. + "/hosts/${hostname}/home.nix")
                        then {
                            extraSpecialArgs = { inherit inputs; };
                            users.wouter = (./. + "/hosts/${hostname}/home.nix");
                        } else {};
                    }
                ];
            };
    in {
        nixosConfigurations = {
            rusty-laptop = mkSystem inputs.nixpkgs "x86_64-linux" "rusty-laptop" [
                inputs.stylix.nixosModules.stylix
                inputs.nixvim.nixosModules.nixvim
            ];
            rusty-desktop = mkSystem inputs.nixpkgs "x86_64-linux" "rusty-desktop" [
                inputs.stylix.nixosModules.stylix
                inputs.nixvim.nixosModules.nixvim
            ];
            rusty-server = mkSystem inputs.nixpkgs "x86_64-linux" "rusty-server" [
                inputs.loodsenboekje.nixosModules.loodsenboekje
            ]; 
        };
        templates = import ./templates;
    };
 }
