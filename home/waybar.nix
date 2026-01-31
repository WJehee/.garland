{ pkgs, ... }: {
    programs.waybar = {
        enable = true;
        settings = [{
            layer = "top";
            position = "top";
            modules-left = [ "hyprland/workspaces" ];
            modules-center = [ "tray" ];
            modules-right = [
                "mpd"
                "wireplumber"
                "custom/spotify"
                "battery"
                "clock"
            ];
            battery = {
                format = "{capacity}% {icon}";
                format-icons = ["" "" "" "" ""];
            };
            clock.format = "{:%a, %d. %b | %H:%M}";
            mpd = {
                format = "{artist} - {title}";
                format-disconnected = "MPD disconnected";
                format-stopped = "MPD stopped";
                tooltip-format = "{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S})";
            };
            tray = {
                icon-size = 24;
                spacing = 10;
            };
            wireplumber = {
                format = "{icon}  {volume}%";
                format-muted = "";
                format-icons = [ "" "" " " ];
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
#tray,
#mode,
#idle_inhibitor,
#scratchpad,
#mpd {
    padding: 0 10px;
    margin: 0 5px;
    color: @base06;
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

#mpd {
    border-bottom: 3px solid @base0E;
}

        '';
    };
}
