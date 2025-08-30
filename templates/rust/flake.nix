{
    description = "Rust template";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        naersk = {
            url = "github:nix-community/naersk";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        fenix = {
            url = "github:nix-community/fenix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, naersk, fenix }:
    let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
            inherit system;
        };
        fenixLib = fenix.packages.${system};

        rust-toolchain = fenixLib.stable.toolchain;
        # rust-coolchain = fenixLib.default.toolchain;

        buildInputs = with pkgs; [
            rust-analyzer
            rustfmt
            cargo-watch
            clippy
        ];
    in {
        devShells.${system}.default = with pkgs; mkShell {
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
}
