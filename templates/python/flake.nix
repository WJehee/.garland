{
    description = "Python template with UV";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
    };

    outputs = { self, flake-parts, ... }@inputs:
        flake-parts.lib.mkFlake { inherit inputs; } {
            systems = [
                "x86_64-linux"
            ];
            perSystem = { pkgs, ... }: {
                devShells.default = with pkgs; mkShell {
                    buildInputs = [
                        uv 
                    ];
                    shellHook = ''
                    '';
                };
            };
        };
}
