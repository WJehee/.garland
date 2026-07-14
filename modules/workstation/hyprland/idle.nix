{
    flake.modules.homeManager.hyprland = {
        services.hypridle = {
            enable = true;
            settings = {
                general = {
                    # Any input within the grace period dismisses the lock screen
                    # without a password, the idle timeout starts hyprlock 60s early
                    lock_cmd = "pidof hyprlock || hyprlock --grace 60";
                    before_sleep_cmd = "loginctl lock-session";
                    after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms(\"on\")'";
                };
                listener = [
                    {
                        # Start the lock screen 60s before the actual lock for fade in with grace period
                        timeout = 540;
                        on-timeout = "loginctl lock-session";
                    }
                    {
                        timeout = 660;
                        on-timeout = "hyprctl dispatch 'hl.dsp.dpms(\"off\")'";
                        on-resume = "hyprctl dispatch 'hl.dsp.dpms(\"on\")'";
                    }
                ];
            };
        };
    };
}
