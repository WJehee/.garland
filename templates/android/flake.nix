{
    description = "Android template";

    inputs = {
        devenv-root = {
            url = "file+file:///dev/null";
            flake = false;
        };
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
        devenv.url = "github:cachix/devenv";
    };

    nixConfig = {
        extra-substituters = "https://devenv.cachix.org";
        extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    };

    outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [
            inputs.devenv.flakeModule
        ];
        systems = [
            "x86_64-linux"
        ];
        perSystem = { system, ... }: {
            # Android Studio and the SDK are unfree, which the default
            # flake-parts pkgs does not allow.
            _module.args.pkgs = import inputs.nixpkgs {
                inherit system;
                config = {
                    allowUnfree = true;
                    android_sdk.accept_license = true;
                };
            };
            devenv.shells.default = {
                imports = [ ./devenv.nix ];
            };
        };
    };
}
