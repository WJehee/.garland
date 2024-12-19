{ lib, ... }: {
    programs.hyprlock = {
        enable = true;
        settings = {
            general = {
                disable_loading_bar = true;
                hide_cursor = true;
            };
            background = lib.mkForce [
                {
                    path = "screenshot";
                    blur_passes = 3;
                    blur_size = 5;
                }
            ];
        };
    };
}
