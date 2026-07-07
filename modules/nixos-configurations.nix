# Every flake.modules.nixos."hosts/<name>" becomes nixosConfigurations.<name>.
# Hosts declare their platform via nixpkgs.hostPlatform.
{ config, inputs, lib, ... }: {
    flake.nixosConfigurations = lib.mapAttrs'
        (name: module: lib.nameValuePair (lib.removePrefix "hosts/" name)
            (inputs.nixpkgs.lib.nixosSystem {
                specialArgs = { inherit inputs; };
                modules = [ module ];
            }))
        (lib.filterAttrs (name: _: lib.hasPrefix "hosts/" name)
            config.flake.modules.nixos);
}
