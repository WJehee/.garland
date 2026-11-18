{
    flake.modules.nixos.gaming = { pkgs, ... }: {
        programs = {
            # Also enables hardware.steam-hardware, the udev rules that give
            # the logged-in user access to Steam Controllers, the Steam Deck
            # and other pads Steam Input handles.
            steam = {
                enable = true;
                gamescopeSession.enable = true;
                # Selectable per game under Properties > Compatibility.
                extraCompatPackages = [ pkgs.proton-ge-bin ];
            };
            gamescope = {
                enable = true;
                # Lets gamescope raise its own scheduling priority, which
                # keeps frame pacing even while the game saturates the CPU.
                capSysNice = true;
            };
            gamemode.enable = true;
        };
        # gamemoded only applies the CPU governor and renice requests of
        # members of this group; for everyone else `gamemoderun` starts the
        # game without changing anything.
        users.users.wouter.extraGroups = [ "gamemode" ];
    };

    flake.modules.homeManager.gaming = { lib, ... }: {
        # Frametime and load overlay: `mangohud %command%` as a Steam launch
        # option, or `gamescope --mangoapp` inside gamescope.
        programs.mangohud.enable = true;

        wayland.windowManager.hyprland.settings = {
            config = {
                # 2 = variable refresh rate only while a window is fullscreen,
                # so the desktop does not flicker on monitors whose brightness
                # shifts with the refresh rate.
                misc.vrr = 2;
                # Only permits tearing; a window tears when it is fullscreen
                # and also carries the `immediate` rule below.
                general.allow_tearing = true;
            };
            # mkAfter for the same reason as the other feature modules: rules
            # must come after hyprland.nix's catch-all "tile everything" rule.
            window_rule = lib.mkAfter [
                {
                    # steam_app_<id> is the class Proton gives every game
                    # window; gamescope is the nested compositor itself.
                    match.class = "^(steam_app_.*|gamescope)$";
                    immediate = true;
                }
            ];
        };
    };
}
