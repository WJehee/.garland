{ lib, ... }: {
    stylix = {
        enable = true;
        autoEnable = true;
        targets = {
            hyprpaper.enable = lib.mkForce false;
            librewolf.profileNames = [ "default" ];
        };
        opacity.terminal = 0.95;
    };
}
