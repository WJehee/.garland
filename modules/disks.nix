# Disk layouts live in _disk/ as plain NixOS modules (underscored so
# import-tree skips them): luks-lvm.nix takes a `disk` argument that only
# nixos-anywhere supplies at install time.
{ inputs, ... }: {
    flake.modules.nixos."disk/luks-lvm" = {
        imports = [
            inputs.disko.nixosModules.disko
            ./_disk/luks-lvm.nix
        ];
    };
    flake.modules.nixos."disk/server" = {
        imports = [
            inputs.disko.nixosModules.disko
            ./_disk/server.nix
        ];
    };
}
