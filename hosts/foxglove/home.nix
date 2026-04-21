{ lib, pkgs, vars, ... }:
let
    monitorWorkspaces = pkgs.writeShellScriptBin "hypr-monitor-workspaces" ''
        setup_workspaces() {
            monitors=$(hyprctl monitors -j)

            assign_workspace() {
                local ws=$1 monitor=$2 extra=''${3:-}
                hyprctl keyword workspace "$ws, monitor:$monitor''${extra:+, $extra}"
                hyprctl dispatch moveworkspacetomonitor "$ws $monitor" 2>/dev/null
            }

            if ${pkgs.jq}/bin/jq -e '.[] | select(.name == "DP-6")' > /dev/null 2>&1 <<< "$monitors"; then
                # Docked: spread workspaces across external monitors
                for ws in 1 2 3 4 5; do assign_workspace "$ws" DP-6; done
                for ws in 6 7 8 9; do assign_workspace "$ws" DP-5 "layoutopt:orientation:top"; done
                assign_workspace 10 eDP-1
            else
                ext=$(${pkgs.jq}/bin/jq -r '.[] | select(.name != "eDP-1") | .name' <<< "$monitors" | head -1)
                if [ -n "$ext" ]; then
                    # Single external monitor: workspaces 1-7 on it, 8-10 on laptop
                    for ws in 1 2 3 4 5 6 7; do assign_workspace "$ws" "$ext"; done
                    for ws in 8 9 10; do assign_workspace "$ws" eDP-1; done
                else
                    # Undocked: all workspaces on laptop screen
                    for ws in $(seq 1 10); do assign_workspace "$ws" eDP-1; done
                fi
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
            "eDP-1, preferred, auto, 1.2"
            "DP-5, preferred, auto-left, 1, transform, 1"
            "DP-6, preferred, auto-left, 1"
        ];
        exec = [
            "${monitorWorkspaces}/bin/hypr-monitor-workspaces"
        ];
    };
    xdg.configFile = lib.mkIf (vars.garland.windowManager == "hyprland") {
        "hypr/hyprpaper.conf".text = ''
            splash = 0

            wallpaper {
                monitor = eDP-1
                path = ${vars.garland.wallpaper.landscape}
                fit_mode = cover
            }

            wallpaper {
                monitor = DP-5
                path = ${vars.garland.wallpaper.portrait}
                fit_mode = cover
            }
            
            wallpaper {
                monitor = DP-6
                path = ${vars.garland.wallpaper.landscape}
                fit_mode = cover
            }
        '';
    };
}
