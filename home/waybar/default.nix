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

@define-color base00 #${config.colorScheme.colors.base00};
@define-color base01 #${config.colorScheme.colors.base01};
@define-color base02 #${config.colorScheme.colors.base02};
@define-color base03 #${config.colorScheme.colors.base03};
@define-color base04 #${config.colorScheme.colors.base04};
@define-color base05 #${config.colorScheme.colors.base05};
@define-color base06 #${config.colorScheme.colors.base06};
@define-color base07 #${config.colorScheme.colors.base07};
@define-color base08 #${config.colorScheme.colors.base08};
@define-color base09 #${config.colorScheme.colors.base09};
@define-color base0A #${config.colorScheme.colors.base0A};
@define-color base0B #${config.colorScheme.colors.base0B};
@define-color base0C #${config.colorScheme.colors.base0C};
@define-color base0D #${config.colorScheme.colors.base0D};
@define-color base0E #${config.colorScheme.colors.base0E};
@define-color base0F #${config.colorScheme.colors.base0F};

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
