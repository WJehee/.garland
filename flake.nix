{
    description = "Garland - Nix Configurations";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        import-tree.url = "github:vic/import-tree";
        home-manager.url = "github:nix-community/home-manager";
        disko.url = "github:nix-community/disko";
        stylix.url = "github:danth/stylix";
        nixvim.url = "github:nix-community/nixvim";
        nixos-hardware.url = "github:nixos/nixos-hardware/master";
        sops-nix.url = "github:Mic92/sops-nix";

        # My own flakes
        loodsenboekje.url = "github:wjehee/loodsenboekje.com";
        galeharp.url = "github:WJehee/galeharp";
    };

    # Dendritic pattern: every file under modules/ is a flake-parts module,
    # discovered automatically. Files and directories prefixed with an
    # underscore are skipped.
    outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
        (inputs.import-tree ./modules);
}
