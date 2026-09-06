# Night light via noctalia's built-in wlr-gamma-control scheduler (it
# replaced gammastep). Day and night are computed from the location; the
# nightlight bar widget in noctalia.nix toggles or forces it.
{
    flake.modules.homeManager.workstation = { ... }: {
        programs.noctalia.settings = {
            nightlight = {
                enabled = true;
                # Same temperatures gammastep used
                temperature_day = 5500;
                temperature_night = 3700;
            };
            # Coordinates from the IP address (gammastep got them from
            # geoclue, which noctalia does not talk to); also feeds weather
            location.auto_locate = true;
        };
    };
}
