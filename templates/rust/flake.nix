{
    description = "Rust template";

    inputs = {
        devenv-root = {
            url = "file+file:///dev/null";
            flake = false;
        };
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
        devenv.url = "github:cachix/devenv";
        rust-overlay = {
            url = "github:oxalica/rust-overlay";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        naersk = {
            url = "github:nix-community/naersk";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    nixConfig = {
        extra-substituters = "https://devenv.cachix.org";
        extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    };

    outputs = inputs@{ flake-parts, naersk, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [
            inputs.devenv.flakeModule
        ];
        systems = [
            "x86_64-linux"
        ];
        perSystem = { system, pkgs, ... }: let
            # The same toolchain rust-overlay resolves for the devenv shell,
            # so `nix build` compiles with exactly what you develop against.
            rust-toolchain = (inputs.rust-overlay.lib.mkRustBin { } pkgs).stable.latest.default;
        in {
            devenv.shells.default = {
                imports = [ ./devenv.nix ];
            };
            packages.default = (naersk.lib.${system}.override {
                cargo = rust-toolchain;
                rustc = rust-toolchain;
            }).buildPackage {
                src = ./.;
            };
        };
    };
}
