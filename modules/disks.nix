# Disk layouts live in _disk/ as plain NixOS modules (underscored so
# import-tree skips them). luks-lvm.nix takes a `disk` argument and
# luks-lvm-span.nix a `disks` list; the importing host supplies them through
# `_module.args`, and they are only read when partitioning at install time.
{ inputs, ... }: {
    flake.modules.nixos."disk/luks-lvm" = {
        imports = [
            inputs.disko.nixosModules.disko
            ./_disk/luks-lvm.nix
        ];
    };
    flake.modules.nixos."disk/luks-lvm-span" = {
        imports = [
            inputs.disko.nixosModules.disko
            ./_disk/luks-lvm-span.nix
        ];
    };
    flake.modules.nixos."disk/server" = {
        imports = [
            inputs.disko.nixosModules.disko
            ./_disk/server.nix
        ];
    };
}
