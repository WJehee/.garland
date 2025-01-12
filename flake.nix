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
        spicetify-nix = {
            url = "github:Gerg-L/spicetify-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        loodsenboekje.url = "github:wjehee/loodsenboekje.com";
    };

    outputs = { nixpkgs, home-manager, ... }@inputs: let
        systems = [ "x86_64-linux" ];
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
                    inputs.spicetify-nix.nixosModules.default
                    inputs.loodsenboekje.nixosModules.loodsenboekje

                    home-manager.nixosModules.home-manager {
                        home-manager = if builtins.pathExists ./nixos/${hostname}/home.nix
                            then {
                                extraSpecialArgs = { inherit inputs; };
                                users.wouter = ./nixos/${hostname}/home.nix;
                                useGlobalPkgs = true;
                                useUserPackages = true;
                            } else {};
                    }
                ];
            };
    in {
        nixosConfigurations = {
            rusty-laptop = mkSystem "x86_64-linux" "rusty-laptop";
            rusty-desktop = mkSystem "x86_64-linux" "rusty-desktop";
            rusty-server = mkSystem "x86_64-linux" "rusty-server"; 
        };
        diskoConfigurations.disko = import ./nixos/disk-config.nix;
        templates = import ./templates;
        nvim = inputs.nixvim.legacyPackages.x86_64-linux.makeNixvimWithModule {
            module = import ../modules/dev/nvim.nix;
            extraSpecialArgs.inputs = inputs;
        };
        packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    };
}

