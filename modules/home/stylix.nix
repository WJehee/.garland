{ lib, ... }: {
    stylix = {
        enable = true;
        autoEnable = true;
        targets = {
            hyprpaper.enable = lib.mkForce false;
        };
        opacity.terminal = 0.95;
    };
}
