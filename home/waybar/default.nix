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
            clock.format-alt = "{:%a, %d. %b | %H:%M}";
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

@define-color base00 #2e3440;
@define-color base01 #3b4252;
@define-color base02 #434c5e;
@define-color base03 #4c566a;
@define-color base04 #d8dee9;
@define-color base05 #e5e9f0;
@define-color base06 #eceff4;
@define-color base07 #8fbcbb;
@define-color base08 #bf616a;
@define-color base09 #d08770;
@define-color base0A #ebcb8b;
@define-color base0B #a3be8c;
@define-color base0C #88c0d0;
@define-color base0D #81a1c1;
@define-color base0E #b48ead;
@define-color base0F #5e81ac;

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
