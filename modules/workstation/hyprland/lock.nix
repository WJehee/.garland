{
    flake.modules.homeManager.hyprland = { lib, ... }: {
        programs.hyprlock = {
            enable = true;
            settings = {
                general = {
                    disable_loading_bar = true;
                    hide_cursor = true;
                    # Grace period is set via `hyprlock --grace` in hypridle's
                    # lock_cmd; since v0.9 the general:grace config option is gone
                };
                animations = {
                    enabled = true;
                    animation = [
                        "fadeIn, 1, 100, linear"
                        "fadeOut, 1, 5, linear"
                    ];
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
    };
}
