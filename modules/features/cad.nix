{
    flake.modules.nixos.cad = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            # freecad
            openscad
        ];
    };
}
