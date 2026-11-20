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
                # capSysNice stays off: it replaces `gamescope` with a
                # capability wrapper in /run/wrappers, and such wrappers
                # refuse to run inside Steam's bubblewrap sandbox (it sets
                # no_new_privs). A `gamescope ... -- %command%` launch option
                # then exits before the game starts. The cost is that
                # gamescope cannot raise its own scheduling priority.
                capSysNice = false;
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
                {
                    # Elden Ring (Steam app id 1245620) reports "fullscreen" in
                    # its own settings but only opens a monitor-sized X11
                    # window, which Hyprland then tiles below the bar like any
                    # other window. Fullscreening it from the compositor side
                    # does not depend on what the game requests. The Easy
                    # Anti-Cheat splash shares the class, so it is fullscreened
                    # too for the few seconds it is shown.
                    match.class = "^steam_app_1245620$";
                    fullscreen = true;
                }
            ];
        };
    };
}
