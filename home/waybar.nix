{ pkgs, ... }: {
    programs.waybar = {
        enable = true;
        settings = [{
            layer = "top";
            modules-left = [ "hyprland/workspaces" ];
            modules-right = [
                "custom/spotify"
                "wireplumber"
                "battery"
                "clock"
                "tray"
            ];
            battery = {
                format = "{capacity}% {icon}";
                format-icons = ["" "" "" "" ""];
            };
            clock.format = "{:%a, %d. %b | %H:%M}";
            tray = {
                icon-size = 24;
                spacing = 10;
            };
            wireplumber = {
                format = "{icon}  {volume}%";
                format-muted = "";
                format-icons = [ "" "" " " ];
            };
            "custom/spotify" = {
                interval = 1;
                return-type = "json";
                exec-if = "pgrep spotify";
                exec = pkgs.writeShellScript "spotify-waybar" ''
                    class=$(playerctl metadata --player=spotify --format '{{lc(status)}}')
                    icon=""

                    if [[ $class == "playing" ]]; then
                      info=$(playerctl metadata --player=spotify --format '{{artist}} - {{title}}')
                      text=$info"  "$icon
                    elif [[ $class == "paused" ]]; then
                      text=$icon
                    elif [[ $class == "stopped" ]]; then
                      text=""
                    fi

                    echo -e "{\"text\":\""$text"\", \"class\":\""$class"\"}"
                '';
            };
        }];
        style = ''
window#waybar {
    background-color: @base00;
}

#workspaces button,
#workspaces button.active,
#workspaces button.visible,
#workspaces button.urgent,
#workspaces button.persistent,
#workspaces button.hidden {
    background-color: transparent;
}

#workspaces button {
    color: @base03;
}

#workspaces button.active {
    color: @base06;
}

#clock,
#battery,
#cpu,
#memory,
#disk,
#temperature,
#backlight,
#network,
#pulseaudio,
#wireplumber,
#custom-media,
#custom-spotify,
#tray,
#mode,
#idle_inhibitor,
#scratchpad,
#mpd {
    padding: 0 10px;
    margin: 0 5px;
    color: @base06;
}

#custom-spotify {
    border-bottom: 3px solid @base0B;
}

#battery {
    border-bottom: 3px solid @base0A;
}

#clock {
    border-bottom: 3px solid @base0C;
}

#wireplumber {
    border-bottom: 3px solid @base09;
}

        '';
    };
}
