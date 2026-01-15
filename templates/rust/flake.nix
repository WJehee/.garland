{
    description = "Rust template";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        naersk.url = "github:nix-community/naersk";
        fenix.url = "github:nix-community/fenix";
    };

    outputs = { self, naersk, fenix, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
        systems = [
            "x86_64-linux"
        ];
        perSystem = { system, pkgs, ... }: let 
            rust-toolchain = fenix.packages.${system}.stable.toolchain;
            buildInputs = with pkgs; [
                rust-analyzer
                rustfmt
                cargo-watch
                clippy
            ];
        in {
            devShells.default = with pkgs; mkShell {
                buildInputs = buildInputs ++ [ rust-toolchain ];
                shellHook = ''
                '';
            };
            packages.${system}.default = naersk.lib.${system}.override {
                cargo = rust-toolchain;
                rustc = rust-toolchain;
            }.buildPackage {
                src = ./.;
                buildInputs = buildInputs;
            };
        };
    };
}
