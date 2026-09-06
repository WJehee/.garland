# Noctalia is the desktop shell: bar, launcher, notifications, OSD,
# clipboard history, lock screen and idle handling in one process.
# Colors, font and the default wallpaper come from the stylix target.
# Wallpapers themselves are still drawn by hyprpaper (see the hosts).
{
    flake.modules.nixos.workstation = {
        programs.noctalia = {
            enable = true;
            # UPower (battery widget), power-profiles-daemon, NetworkManager, Bluetooth
            recommendedServices.enable = true;
        };
    };

    flake.modules.homeManager.workstation = {
        programs.noctalia = {
            enable = true;
            # Systemd user service on graphical-session.target: Hyprland's
            # systemd.enable restarts hyprland-session.target at startup, which
            # kills anything exec'd from the autostart hook, but a managed
            # service is restarted along with the target.
            systemd.enable = true;
            # Runtime changes made in the settings GUI land in
            # ~/.local/state/noctalia/settings.toml and override this file;
            # copy anything worth keeping back here and delete that file.
            settings = {
                shell = {
                    # Apps started from the launcher become transient systemd
                    # units so they survive a shell restart
                    launch_apps_as_systemd_services = true;
                    # hyprpolkitagent is started from the Hyprland autostart hook
                    polkit_agent = false;

                    # Attached panels open centered along the bar; pin the
                    # control center (and the session menu opened from it) to
                    # the top right corner, under the widgets that open it.
                    # A pinned position also applies to the mainMod + S bind,
                    # unlike open_near_click_* which needs a mouse click.
                    panel = {
                        control_center_placement = "floating";
                        control_center_position = "top_right";
                        session_placement = "floating";
                        session_position = "top_right";
                        # Flush against the edge to edge bar
                        floating_offset = 0;
                    };
                };

                # hyprpaper draws the wallpapers, per monitor, see the host files
                wallpaper.enabled = false;

                # Replaces dunst
                notification.enable_daemon = true;

                # Open-Meteo, for the bar widget and the control center tab;
                # uses the [location] coordinates (nightlight.nix, location.nix)
                weather = {
                    enabled = true;
                    unit = "celsius";
                };

                bar.main = {
                    position = "top";
                    reserve_space = true;
                    # A bit taller and larger than the defaults (34 / 1.0)
                    thickness = 40;
                    scale = 1.15;
                    # Edge to edge instead of a floating pill
                    margin_ends = 0;
                    margin_edge = 0;
                    radius = 0;
                    # Each widget sits in its own slightly lighter capsule so
                    # the items are visually separated
                    capsule = true;
                    capsule_fill = "surface_variant";
                    capsule_radius = 6;
                    widget_spacing = 10;
                    start = [ "workspaces" ];
                    # No tray: the applets it used to show (nm-applet,
                    # blueman-applet, gammastep, udiskie) are replaced by the
                    # network, bluetooth and nightlight widgets below, and the
                    # remaining tray icon (keepassxc) was never used
                    center = [ ];
                    end = [
                        "caffeine"
                        "nightlight"
                        "media"
                        "volume"
                        "network"
                        "bluetooth"
                        "disk"
                        "battery"
                        "weather"
                        "clock"
                        "notifications"
                        "control-center"
                    ];
                };

                widget = {
                    workspaces = {
                        label_source = "id";
                        # The workspace pills are distinct enough on their own
                        capsule = false;
                    };
                    disk = {
                        type = "sysmon";
                        stat = "disk_used_pct";
                        path = "/";
                    };
                    media = {
                        artist_first = true;
                        hide_when_no_media = true;
                    };
                    # Icon only; the SSID / device name is in the tooltip
                    network.show_label = false;
                    bluetooth.show_label = false;
                    # Glyph and temperature; the condition text is in the
                    # tooltip and the control center weather tab
                    weather.show_condition = false;
                    clock.format = "{:%a, %d. %b | %H:%M}";
                };

                # Replaces hyprlock: a blurred snapshot of the desktop. Locking
                # before suspend (lid close) is on by default.
                lockscreen = {
                    enabled = true;
                    blurred_desktop = true;
                };

                # Replaces hypridle; caffeine (the bar widget or
                # `noctalia msg caffeine-toggle`) inhibits these
                idle = {
                    # Fade the screen out before locking; any input cancels
                    pre_action_fade_seconds = 5;
                    behavior = {
                        lock = {
                            timeout = 600;
                            action = "lock";
                            enabled = true;
                        };
                        screen-off = {
                            timeout = 660;
                            action = "screen_off";
                            enabled = true;
                        };
                    };
                };
            };
        };
    };

    flake.modules.homeManager.hyprland = { lib, ... }:
    let
        inherit (lib.generators) mkLuaInline;
        msg = cmd: mkLuaInline ''hl.dsp.exec_cmd("noctalia msg ${cmd}")'';
        modBind = combo: cmd: { _args = [ (mkLuaInline ''mainMod .. " + ${combo}"'') (msg cmd) ]; };
        keyBind = key: cmd: { _args = [ key (msg cmd) ]; };
    in {
        wayland.windowManager.hyprland.settings = {
            bind = [
                (modBind "S" "panel-toggle control-center")
                (modBind "comma" "settings-toggle")
                (keyBind "XF86AudioRaiseVolume" "volume-up")
                (keyBind "XF86AudioLowerVolume" "volume-down")
                (keyBind "XF86AudioMute" "volume-mute")
                (keyBind "XF86MonBrightnessUp" "brightness-up")
                (keyBind "XF86MonBrightnessDown" "brightness-down")
            ];

            # Hyprland's layer animations fight with noctalia's own
            layer_rule = [
                {
                    name = "noctalia";
                    match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
                    no_anim = true;
                }
            ];

            # The settings window is a normal toplevel; float it. mkAfter puts
            # the rule behind hyprland.nix's "tile everything" rule.
            window_rule = lib.mkAfter [
                {
                    match.class = "dev.noctalia.Noctalia";
                    float = true;
                    center = true;
                }
            ];
        };
    };
}
