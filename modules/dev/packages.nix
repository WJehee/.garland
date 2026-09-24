{
    flake.modules.nixos.dev = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            devenv
            gh
            secretspec
            sops
        ];
    };
}
