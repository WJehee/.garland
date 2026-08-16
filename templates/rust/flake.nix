{
    description = "Rust template";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        rust-overlay = {
            url = "github:oxalica/rust-overlay";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        naersk = {
            url = "github:nix-community/naersk";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs@{ flake-parts, naersk, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
        systems = [
            "x86_64-linux"
        ];
        perSystem = { system, pkgs, ... }: let
            # Same source as the devenv shell toolchain (rust-overlay stable).
            rust-toolchain = (inputs.rust-overlay.lib.mkRustBin { } pkgs).stable.latest.default;
        in {
            packages.default = (naersk.lib.${system}.override {
                cargo = rust-toolchain;
                rustc = rust-toolchain;
            }).buildPackage {
                src = ./.;
            };
        };
    };
}
