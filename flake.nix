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
        deploy-rs = {
            url = "github:serokell/deploy-rs";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Private NixOS config
        wreath.url = "git+ssh://git@github.com/WJehee/.wreath.git";

        loodsenboekje.url = "github:wjehee/loodsenboekje.com";
        galeharp = {
            url = "github:WJehee/galeharp";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };
    outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [
            (inputs.import-tree ./modules)
            inputs.wreath.flakeModules.default
        ];
    };
}
