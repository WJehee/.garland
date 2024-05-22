{ config, ... }: {
    programs.waybar = {
        enable = true;
        settings = [{
            layer = "top";
            modules-left = ["hyprland/workspaces"];
            modules-right = [
                "wireplumber"
                "network"
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
                icon-size = 21;
                spacing = 10;
            };
        }];
        style = ''
/*
*
* Base16 Nord
* Author: arcticicestudio
*
*/

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
#tray,
#mode,
#idle_inhibitor,
#scratchpad,
#mpd {
    padding: 0 10px;
    color: @base06;
}
        '';
    };
}
