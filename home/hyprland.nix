{ ... }: {
    wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        settings = {
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
                    natural_scroll = "no";
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
                enabled = "yes";
                bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

                animation = [
                    "windows, 1, 7, myBezier"
                        "windowsOut, 1, 7, default, popin 80%"
                        "border, 1, 10, default"
                        "borderangle, 1, 8, default"
                        "fade, 1, 7, default"
                        # turn off workspace animations
                        "workspaces, 0, 6, default"
                ];
            };
            gestures = {
                workspace_swipe = "off";
            };
            misc = {
                disable_hyprland_logo = true;
                disable_splash_rendering = true;
                mouse_move_focuses_monitor = false;
            };
            ecosystem.no_update_news = true;

            # Keybinds
            "$mainMod" = "SUPER";
            bind = [
                "$mainMod, F, exec, $BROWSER"                                       # Open browser
                "$mainMod, Return, exec, $TERMINAL"                                 # Open terminal
                "$mainMod SHIFT, Return, exec, wofi --show run --normal-window"     # Run application launcher
                "$mainMod, Q, killactive,"                                          # Kill focused window
                "$mainMod SHIFT, L, exec, hyprlock"                                 # Lock screen
                "$mainMod, M, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"     # Mute toggle
                "$mainMod SHIFT, s, exec, hyprshot -m region -z --clipboard-only"   # Screenshot

                # Move focus with mainMod + h j k l
                "$mainMod, L, movefocus, r"
                "$mainMod, H, movefocus, l"
                "$mainMod, K, movefocus, u"
                "$mainMod, J, movefocus, d"

                # Switch workspaces with mainMod + [0-9]
                "$mainMod, 1, workspace, 1"
                "$mainMod, 2, workspace, 2"
                "$mainMod, 3, workspace, 3"
                "$mainMod, 4, workspace, 4"
                "$mainMod, 5, workspace, 5"
                "$mainMod, 6, workspace, 6"
                "$mainMod, 7, workspace, 7"
                "$mainMod, 8, workspace, 8"
                "$mainMod, 9, workspace, 9"
                "$mainMod, 0, workspace, 10"

                # Move active window to a workspace with mainMod + SHIFT + [0-9]
                "$mainMod SHIFT, 1, movetoworkspace, 1"
                "$mainMod SHIFT, 2, movetoworkspace, 2"
                "$mainMod SHIFT, 3, movetoworkspace, 3"
                "$mainMod SHIFT, 4, movetoworkspace, 4"
                "$mainMod SHIFT, 5, movetoworkspace, 5"
                "$mainMod SHIFT, 6, movetoworkspace, 6"
                "$mainMod SHIFT, 7, movetoworkspace, 7"
                "$mainMod SHIFT, 8, movetoworkspace, 8"
                "$mainMod SHIFT, 9, movetoworkspace, 9"
                "$mainMod SHIFT, 0, movetoworkspace, 10"

                "$mainMod, v, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

                # Hacking stuff
                ''
                    $mainMod SHIFT, W, exec, find $(wordlists_path) | wofi -i --dmenu -M fuzzy | tr --delete "\n" | wl-copy
                ''
            ];
            bindm = [
                # Move/resize windows with mainMod + LMB/RMB and dragging
                "$mainMod, mouse:272, movewindow"
                "$mainMod, mouse:273, resizewindow"
            ];
            exec-once = [
                "waybar"
                "hyprpaper"
                "nm-applet"
                "systemctl --user start hyprpolkitagent"
            ];
            env = [
                "XCURSOR_SIZE,24"
                "MOZ_ENABLE_WAYLAND,1"
                "_JAVA_AWT_WM_NONREPARENTING,1"
            ];
            windowrulev2 = [
                # Make --normal-window look as before for wofi
                "stayfocused,class:(wofi)"
                "noborder,class:(wofi)"
                # Make ssh-askpass always focused
                "stayfocused,class:(SshAskpass)"
            ];
        };
    };
}
