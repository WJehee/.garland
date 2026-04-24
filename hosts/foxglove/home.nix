{ lib, pkgs, vars, ... }:
let
    monitorWorkspaces = pkgs.writeShellScriptBin "hypr-monitor-workspaces" ''
        setup_workspaces() {
            monitors=$(hyprctl monitors -j)

            # Resolve current port name (e.g. DP-7) from a substring of the monitor description
            find_monitor() {
                ${pkgs.jq}/bin/jq -r --arg d "$1" \
                    '.[] | select(.description | contains($d)) | .name' <<< "$monitors" | head -1
            }

            assign_workspace() {
                local ws=$1 monitor=$2 extra=''${3:-}
                hyprctl keyword workspace "$ws, monitor:$monitor''${extra:+, $extra}"
                hyprctl dispatch moveworkspacetomonitor "$ws $monitor" 2>/dev/null
            }

            laptop=$(find_monitor "BOE")
            primary=$(find_monitor "P2720D")
            portrait=$(find_monitor "P2416D")

            if [ -n "$primary" ] && [ -n "$portrait" ]; then
                # Docked: spread workspaces across external monitors
                for ws in 1 2 3 4 5; do assign_workspace "$ws" "$primary"; done
                for ws in 6 7 8 9; do assign_workspace "$ws" "$portrait" "layoutopt:orientation:top"; done
                assign_workspace 10 "$laptop"
            elif [ -n "$primary" ] || [ -n "$portrait" ]; then
                # Single external monitor: workspaces 1-7 on it, 8-10 on laptop
                ext=''${primary:-$portrait}
                for ws in 1 2 3 4 5 6 7; do assign_workspace "$ws" "$ext"; done
                for ws in 8 9 10; do assign_workspace "$ws" "$laptop"; done
            else
                # Undocked: all workspaces on laptop screen
                for ws in $(seq 1 10); do assign_workspace "$ws" "$laptop"; done
            fi
        }

        # Kill any previous instance and register this one
        pidfile=/tmp/hypr-monitor-workspaces.pid
        if [ -f "$pidfile" ]; then
            kill "$(cat $pidfile)" 2>/dev/null || true
        fi
        echo $$ > "$pidfile"

        sleep 1
        setup_workspaces

        while true; do
            ${pkgs.socat}/bin/socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" \
                | while IFS= read -r line; do
                    case "$line" in
                        monitoradded*|monitorremoved*)
                            sleep 0.5
                            setup_workspaces
                            ;;
                    esac
                done
            sleep 1
        done
    '';
in
{
    imports = [
        ../../modules/home/default.nix
        ../../modules/home/freetube.nix
    ];
    wayland.windowManager.hyprland.settings = lib.mkIf (vars.garland.windowManager == "hyprland") {
        monitor = [
            ", preferred, auto, 1"
            "desc:BOE NE135A1M-NY1, preferred, auto, 1.2"
            "desc:Dell Inc. DELL P2416D 6RC2C5BB08FL, preferred, auto-left, 1, transform, 1"
            "desc:Dell Inc. DELL P2720D JV69F9AP02VS, preferred, auto-left, 1"
        ];
        exec = [
            "${monitorWorkspaces}/bin/hypr-monitor-workspaces"
        ];
    };
    xdg.configFile = lib.mkIf (vars.garland.windowManager == "hyprland") {
        "hypr/hyprpaper.conf".text = ''
            splash = 0

            wallpaper {
                monitor = desc:BOE NE135A1M-NY1
                path = ${vars.garland.wallpaper.landscape}
                fit_mode = cover
            }

            wallpaper {
                monitor = desc:Dell Inc. DELL P2416D 6RC2C5BB08FL
                path = ${vars.garland.wallpaper.portrait}
                fit_mode = cover
            }

            wallpaper {
                monitor = desc:Dell Inc. DELL P2720D JV69F9AP02VS
                path = ${vars.garland.wallpaper.landscape}
                fit_mode = cover
            }
        '';
    };
}
