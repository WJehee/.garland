{ inputs, ... }: let 
    mkSystem = hostname:
        inputs.nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs hostname; };
            modules = [
                { networking.hostName = hostname; }
                ./${hostname}/configuration.nix
                ./${hostname}/hardware-configuration.nix

                inputs.disko.nixosModules.disko
                inputs.stylix.nixosModules.stylix
                inputs.nixvim.nixosModules.nixvim
                inputs.sops-nix.nixosModules.sops
                inputs.authentik-nix.nixosModules.default

                # My custom flakes 
                inputs.loodsenboekje.nixosModules.loodsenboekje

                inputs.home-manager.nixosModules.home-manager {
                    home-manager = if builtins.pathExists ./${hostname}/home.nix
                        then {
                        extraSpecialArgs = { inherit inputs; };
                        users.wouter = ./${hostname}/home.nix;
                        useGlobalPkgs = true;
                        useUserPackages = true;
                    } else {};
                }
            ];
        };
in {
    flake = {
        nixosConfigurations = {
            foxglove = mkSystem "foxglove";
            hemlock = mkSystem "hemlock";
            wisteria = mkSystem "wisteria"; 
            ivy = inputs.nixpkgs.lib.nixosSystem {
                system = "aarch64-linux";
                specialArgs = { inherit inputs; hostname = "ivy"; };
                modules = [
                    inputs.nixos-hardware.nixosModules.raspberry-pi-3
                    inputs.sops-nix.nixosModules.sops
                    ./ivy/configuration.nix
                ];
            };
        };
    };
}
