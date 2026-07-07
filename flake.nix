{
    description = "Garland - Nix Configurations";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        flake-parts = {
            url = "github:hercules-ci/flake-parts";
            inputs.nixpkgs-lib.follows = "nixpkgs";
        };
        import-tree.url = "github:vic/import-tree";
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
        nixos-hardware = {
            url = "github:nixos/nixos-hardware/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # My own flakes
        # No nixpkgs follows: the Leptos build needs wasm-bindgen-cli from
        # nixpkgs to exactly match the wasm-bindgen crate in its Cargo.lock,
        # so it must build against its own pinned nixpkgs
        loodsenboekje.url = "github:wjehee/loodsenboekje.com";
        galeharp = {
            url = "github:WJehee/galeharp";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    # Dendritic pattern: every file under modules/ is a flake-parts module,
    # discovered automatically. Files and directories prefixed with an
    # underscore are skipped.
    outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
        (inputs.import-tree ./modules);
}
