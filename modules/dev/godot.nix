{
    flake.modules.nixos."dev/godot" = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            godot_4
        ];
    };
}
