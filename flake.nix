{
    description = "My NixOS config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager.url = "github:nix-community/home-manager/release-23.05";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        hyprland.url = "github:hyprwm/Hyprland";
        nix-colors.url = "github:misterio77/nix-colors";
    };

    outputs = { nixpkgs, home-manager, hyprland, nix-colors, ... }@inputs:
    let 
        mkSystem = pkgs: system: hostname:
            pkgs.lib.nixosSystem {
                system = system;
                specialArgs = { inherit inputs; };
                modules = [
                    { networking.hostName = hostname; }
                    (./. + "/hosts/${hostname}/hardware-configuration.nix")
                    ./modules/system/default.nix

                    home-manager.nixosModules.home-manager {
                        home-manager = {
                            extraSpecialArgs = { inherit inputs; };
                            users.wouter = (./. + "/hosts/${hostname}/configuration.nix");
                        };
                    }
                ];
            };
    in {
        nixosConfigurations = {
            rusty-laptop = mkSystem inputs.nixpkgs "x86_64-linux" "rusty-laptop";
        };
    };
}
