{
    flake.modules.homeManager.hyprland = { lib, ... }:
    let
        inherit (lib.generators) mkLuaInline;
        inherit (lib) range;

        # `mainMod .. " + <combo>"` -- key combo prefixed with the main modifier
        mod = combo: mkLuaInline ''mainMod .. " + ${combo}"'';
        # raw Lua expression (dispatcher call, etc.)
        raw = expr: mkLuaInline expr;

        # hl.bind(keys, dispatch[, opts])
        bind = keys: dispatch: { _args = [ keys dispatch ]; };
        bindOpt = keys: dispatch: opts: { _args = [ keys dispatch opts ]; };

        # workspace 10 lives on the `0` key
        wsKey = n: if n == 10 then "0" else toString n;
    in {
        # Importing this module is what selects hyprland as the window manager,
        # so it also puts the workspaces widget in the bar
        programs.waybar.settings.mainBar.modules-left = [ "hyprland/workspaces" ];

        services.blueman-applet.enable = true;
        services.network-manager-applet.enable = true;
        # Auto-mount removable media on insert (backend enabled in workstation)
        services.udiskie = {
            enable = true;
            automount = true;
            notify = true;
            tray = "auto";
        };

        wayland.windowManager.hyprland = {
            enable = true;
            systemd.enable = true;
            configType = "lua";
            settings = {
                # local mainMod = "SUPER"
                mainMod = { _var = "SUPER"; };

                # Static keyword sections -> hl.config({ ... })
                config = {
                    general = {
                        gaps_in = 0;
                        gaps_out = 0;
                        border_size = 2;
                        layout = "master";
                    };
                    input = {
                        kb_layout = "us";
                        kb_variant = "";
                        kb_model = "";
                        kb_options = "";
                        kb_rules = "";

                        follow_mouse = 2;

                        touchpad = {
                            natural_scroll = false;
                        };
                        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
                    };
                    decoration = {
                        rounding = 5;
                        shadow = {
                            enabled = true;
                            range = 4;
                            render_power = 3;
                        };
                    };
                    animations = {
                        enabled = true;
                    };
                    misc = {
                        disable_hyprland_logo = true;
                        disable_splash_rendering = true;
                        mouse_move_focuses_monitor = false;
                        middle_click_paste = false;
                    };
                    ecosystem = {
                        no_update_news = true;
                    };
                };

                # hl.curve("myBezier", { type = "bezier", points = { ... } })
                curve = {
                    _args = [
                        "myBezier"
                        { type = "bezier"; points = [ [ 0.05 0.9 ] [ 0.1 1.05 ] ]; }
                    ];
                };

                # hl.animation({ ... }) per leaf
                animation = [
                    { leaf = "windows"; enabled = true; speed = 7; bezier = "myBezier"; }
                    { leaf = "windowsOut"; enabled = true; speed = 7; bezier = "default"; style = "popin 80%"; }
                    { leaf = "border"; enabled = true; speed = 10; bezier = "default"; }
                    { leaf = "borderangle"; enabled = true; speed = 8; bezier = "default"; }
                    { leaf = "fade"; enabled = true; speed = 7; bezier = "default"; }
                    # turn off workspace animations
                    { leaf = "workspaces"; enabled = false; speed = 6; bezier = "default"; }
                ];

                # hl.env("NAME", "value")
                env = [
                    { _args = [ "XCURSOR_SIZE" "24" ]; }
                    { _args = [ "MOZ_ENABLE_WAYLAND" "1" ]; }
                    { _args = [ "_JAVA_AWT_WM_NONREPARENTING" "1" ]; }
                ];

                # hl.bind(keys, dispatcher[, opts])
                bind =
                    [
                        (bind (mod "F") (raw ''hl.dsp.exec_cmd("$BROWSER")''))                                          # Open browser
                        (bind (mod "Return") (raw ''hl.dsp.exec_cmd("$TERMINAL")''))                                    # Open terminal
                        (bind (mod "SHIFT + Return") (raw ''hl.dsp.exec_cmd("wofi --show run --normal-window")''))      # Application launcher
                        (bind (mod "Q") (raw "hl.dsp.window.close()"))                                                  # Kill focused window
                        (bind (mod "SHIFT + L") (raw ''hl.dsp.exec_cmd("hyprlock --no-fade-in")''))                     # Lock screen immediately, no grace
                        (bind (mod "M") (raw ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")''))        # Mute toggle
                        (bind (mod "SHIFT + s") (raw ''hl.dsp.exec_cmd("hyprshot -m region -z --clipboard-only")''))    # Screenshot

                        # Move focus with mainMod + h j k l
                        (bind (mod "L") (raw ''hl.dsp.focus({ direction = "right" })''))
                        (bind (mod "H") (raw ''hl.dsp.focus({ direction = "left" })''))
                        (bind (mod "K") (raw ''hl.dsp.focus({ direction = "up" })''))
                        (bind (mod "J") (raw ''hl.dsp.focus({ direction = "down" })''))

                        (bind (mod "v") (raw ''hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy")''))

                        # Hacking stuff -- [[ ]] keeps the embedded "\n" literal for tr
                        (bind (mod "SHIFT + W") (raw ''hl.dsp.exec_cmd([[find $(wordlists_path) | wofi -i --dmenu -M fuzzy | tr --delete "\n" | wl-copy]])''))

                        # Move/resize windows with mainMod + LMB/RMB and dragging
                        (bindOpt (mod "mouse:272") (raw "hl.dsp.window.drag()") { mouse = true; })
                        (bindOpt (mod "mouse:273") (raw "hl.dsp.window.resize()") { mouse = true; })
                    ]
                    # Switch workspaces with mainMod + [0-9]
                    ++ map (n: bind (mod (wsKey n)) (raw "hl.dsp.focus({ workspace = ${toString n} })")) (range 1 10)
                    # Move active window to a workspace with mainMod + SHIFT + [0-9]
                    ++ map (n: bind (mod ("SHIFT + " + wsKey n)) (raw "hl.dsp.window.move({ workspace = ${toString n} })")) (range 1 10);

                # Autostart -> hl.on("hyprland.start", function() ... end)
                on = {
                    _args = [
                        "hyprland.start"
                        (mkLuaInline ''
                            function()
                                -- waybar, nm-applet and blueman-applet run as systemd user
                                -- services bound to graphical-session.target so they survive the
                                -- hyprland-session.target restart that systemd.enable triggers at
                                -- startup; processes exec'd directly here would be killed by it.
                                hl.exec_cmd("hyprpaper")
                                hl.exec_cmd("systemctl --user start hypridle")
                                hl.exec_cmd("systemctl --user start hyprpolkitagent")
                            end
                        '')
                    ];
                };

                # hl.window_rule({ ... })
                window_rule = [
                    # Tile everything; per-window float rules must come after this one
                    {
                        match = { class = ".*"; };
                        float = false;
                    }
                    # Menus, dropdowns and tooltips of X11 apps (vlc) are
                    # override-redirect windows that request floating; tiling
                    # them breaks them. They cannot be singled out by title
                    # (vlc titles its menu popups "vlc", not ""), so keep every
                    # float-requesting X11 window floating. Since 0.55 rules
                    # match after the requested float state is set, so the
                    # float match works at map time. Wayland windows (gimp tool
                    # windows) and normal X11 windows (hex-kit's Tool Box)
                    # request no floating and stay tiled by the rule above.
                    {
                        match = { xwayland = true; float = true; };
                        float = true;
                    }
                    # Launcher floats centered above the tiled windows
                    {
                        match = { class = "wofi"; };
                        float = true;
                        center = true;
                        border_size = 0;
                        stay_focused = true;
                    }
                ];
            };
        };
    };
}
