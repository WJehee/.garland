{ inputs, lib, ... }: let
    gpuModules = {
        amd   = ../modules/gpu/amd.nix;
        intel = ../modules/gpu/intel.nix;
    };

    mkSystem =
        {
            hostname,
            username ? "wouter",
            gpu ? null,
        }:
        let
            vars = import ./${hostname}/variables.nix;
        in
        inputs.nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs hostname vars; };
            modules = with inputs; [
                { networking.hostName = hostname; }
                ./${hostname}/configuration.nix
                ./${hostname}/hardware-configuration.nix
            ]
            ++ lib.optional (gpu != null) gpuModules.${gpu}
            ++ (with inputs; [
                disko.nixosModules.disko
                stylix.nixosModules.stylix
                nixvim.nixosModules.nixvim
                sops-nix.nixosModules.sops
                loodsenboekje.nixosModules.loodsenboekje

                home-manager.nixosModules.home-manager {
                    home-manager = if builtins.pathExists ./${hostname}/home.nix
                        then {
                        extraSpecialArgs = { inherit inputs vars; };
                        users.${username} = ./${hostname}/home.nix;
                        useGlobalPkgs = true;
                        useUserPackages = true;
                    } else {};
                }
            ]);
        };
in {
    flake = {
        nixosConfigurations = {
            # Workstations
            foxglove = mkSystem { hostname = "foxglove"; gpu = "intel"; };
            wisteria = mkSystem { hostname = "wisteria"; gpu = "amd"; };

            # Other
            hemlock = mkSystem { hostname = "hemlock"; username = "admin"; };
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
