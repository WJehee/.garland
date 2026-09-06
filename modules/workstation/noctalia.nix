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
                };

                # hyprpaper draws the wallpapers, per monitor, see the host files
                wallpaper.enabled = false;

                # Replaces dunst
                notification.enable_daemon = true;

                bar.main = {
                    position = "top";
                    reserve_space = true;
                    start = [ "workspaces" ];
                    center = [ "tray" ];
                    end = [
                        "caffeine"
                        "media"
                        "volume"
                        "disk"
                        "battery"
                        "clock"
                        "notifications"
                        "control-center"
                    ];
                };

                widget = {
                    workspaces.label_source = "id";
                    disk = {
                        type = "sysmon";
                        stat = "disk_used_pct";
                        path = "/";
                    };
                    media = {
                        artist_first = true;
                        hide_when_no_media = true;
                    };
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
