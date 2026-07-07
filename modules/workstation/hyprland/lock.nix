{
    flake.modules.homeManager.hyprland = { lib, ... }: {
        programs.hyprlock = {
            enable = true;
            settings = {
                general = {
                    disable_loading_bar = true;
                    hide_cursor = true;
                    # Any input within the grace period dismisses the lock screen
                    # without a password, hypridle starts hyprlock 60s early
                    grace = 60;
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
