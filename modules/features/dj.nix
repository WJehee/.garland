{
    flake.modules.nixos.dj = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            mixxx
        ];
    };
}
