{ ... }: {
    wayland.windowManager.hyprland = {
        enable = true;
        settings = {
            general = {
                gaps_in = 2;
                gaps_out = 10;
                border_size = 2;
                "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
                "col.inactive_border" = "rgba(595959aa)";
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
                drop_shadow = "yes";
                shadow_range = 4;
                shadow_render_power = 3;
                "col.shadow" = "rgba(1a1a1aee)";
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
            master = {
                new_is_master = false;
            };
            gestures = {
                workspace_swipe = "off";
            };
            "device:epic-mouse-v1" = {
                sensitivity = -0.5;
            };
            misc = {
                disable_hyprland_logo = true;
                disable_splash_rendering = true;
                mouse_move_focuses_monitor = false;
            };
            # Keybinds
            "$mainMod" = "SUPER";
            bind = [
                "$mainMod, Return, exec, alacritty"
                "$mainMod SHIFT, Return, exec, wofi --show run --normal-window"
                "$mainMod, Q, killactive,"
                "$mainMod, M, exit,"
                "$mainMod SHIFT, L, exec, swaylock --screenshots --clock --effect-blur 7x5 --grace 3"
                # Launch programs
                "$mainMod, F, exec, $BROWSER"
                "$mainMod SHIFT, s, exec, screenshot"
                # Layouts
                # "$mainMod, P, pseudo," # dwindle
                # "$mainMod, J, togglesplit," # dwindle
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
            ];
            bindm = [
                # Move/resize windows with mainMod + LMB/RMB and dragging
                "$mainMod, mouse:272, movewindow"
                "$mainMod, mouse:273, resizewindow"
            ];
            exec-once = [
               "dbus-update-activation-environment --systemd --all"
               "waybar"
               "dunst"
               "hyprpaper"
               "swayidle & disown"
               "nm-applet"
               "wl-clip-persist --clipboard both"
               "my-opensnitch"
            ];
            env = [
                "XCURSOR_SIZE,24"
                "MOZ_ENABLE_WAYLAND,1"
                "_JAVA_AWT_WM_NONREPARENTING,1"
            ];
            # Make --normal-window look as before for wofi
            windowrulev2 = [
                "stayfocused,class:(wofi)"
                "noborder,class:(wofi)"
            ];
        };
        extraConfig = ''
monitor=eDP-1,preferred,auto,1.25
monitor=DP-2,preferred,auto,1
monitor=DP-3,preferred,auto,1,transform,1
# monitor=DP-3,preferred,auto,1
monitor=HDMI-A-1,preferred,auto,1

workspace=1, monitor:DP-2, default:true
workspace=2, monitor:DP-2
workspace=3, monitor:DP-2
workspace=4, monitor:DP-2
workspace=5, monitor:DP-2

workspace=6, monitor:DP-1
workspace=6, monitor:DP-3
workspace=7, monitor:DP-3
workspace=8, monitor:DP-3

workspace=9, monitor:HDMI-A-1
workspace=10, monitor:HDMI-A-1
        '';
    };
}
