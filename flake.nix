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
        # firefox-addons = {
        #     url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
        #     inputs.nixpkgs.follows = "nixpkgs";
        # };

        loodsenboekje.url = "github:wjehee/loodsenboekje.com";
    };

    outputs = { nixpkgs, home-manager, ... }@inputs: let
        mkSystem = system: hostname: extra_modules:
            inputs.nixpkgs.lib.nixosSystem {
                system = system;
                specialArgs = { inherit inputs; };
                modules = extra_modules ++ [
                    { networking.hostName = hostname; }
                    ./nixos/${hostname}/configuration.nix
                    ./nixos/${hostname}/hardware-configuration.nix

                    home-manager.nixosModules.home-manager {
                        home-manager = if builtins.pathExists ./nixos/${hostname}/home.nix
                            then {
                                extraSpecialArgs = { inherit inputs; };
                                users.wouter = ./nixos/${hostname}/home.nix;
                            } else {};
                    }
                ];
            };
    in {
        nixosConfigurations = {
            rusty-laptop = mkSystem "x86_64-linux" "rusty-laptop" [
                inputs.stylix.nixosModules.stylix
                inputs.nixvim.nixosModules.nixvim
                inputs.disko.nixosModules.disko
            ];
            rusty-desktop = mkSystem "x86_64-linux" "rusty-desktop" [
                inputs.stylix.nixosModules.stylix
                inputs.nixvim.nixosModules.nixvim
            ];
            rusty-server = mkSystem "x86_64-linux" "rusty-server" [
                inputs.loodsenboekje.nixosModules.loodsenboekje
            ]; 
        };
        diskoConfigurations.disko = import ./nixos/disk-config.nix;
        templates = import ./templates;
        # nvim = inputs.nixvim.legacyPackages.x86_64-linux.makeNixvimWithModule {
        #     module = import ../modules/dev/nvim.nix;
        #     extraSpecialArgs.inputs = inputs;
        # };
    };
}
