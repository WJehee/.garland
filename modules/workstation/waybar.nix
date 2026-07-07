{
    flake.modules.nixos.workstation = {
        nixpkgs.overlays = [
            # TODO: temporary fix -- remove this overlay once nixpkgs ships a Waybar
            # release containing the Hyprland Lua dispatch fix (> 0.15.0, i.e. 0.15.1
            # or a git bump). Then `just update` is enough and this can be deleted.
            #
            # Under the new Hyprland Lua config (configType = "lua", 0.55+), Hyprland
            # runs hyprctl dispatch args through the Lua VM, so Waybar 0.15.0's old
            # `dispatch workspace N` string fails to parse and clicking/scrolling
            # workspaces in waybar does nothing. Fixed upstream in Waybar PR #5013
            # (merged 2026-05-04), but only on master -- no tagged release yet. Pin
            # waybar to the merge commit so clicking switches desktops again.
            (final: prev: {
                waybar = prev.waybar.overrideAttrs (old: {
                    version = "0.15.0-unstable-2026-05-04";
                    src = final.fetchFromGitHub {
                        owner = "Alexays";
                        repo = "Waybar";
                        rev = "05945748dccce28bf96d26d8f64a9e69a8dd49ba";
                        hash = "sha256-51R3mIt8cLNvh/X5qe9vOqeJCj0U9KRyemVE5y+OhiU=";
                    };
                    # The nixpkgs derivation vendors libcava into the meson subproject
                    # dir `cava-0.10.7-beta` (matching the 0.15.0 wrap). Master renamed
                    # the wrap's `directory` to `cava-0.10.7`, so it no longer finds the
                    # vendored copy and tries a (disabled) wrap download. Point the wrap
                    # back at the dir nixpkgs actually provides. replace-fail errors out
                    # if the string ever changes, so this can't silently rot.
                    postPatch = (old.postPatch or "") + ''
                        substituteInPlace subprojects/libcava.wrap \
                            --replace-fail 'directory = cava-0.10.7' 'directory = cava-0.10.7-beta'
                    '';
                    # The master commit still self-reports "v0.15.0", so the version
                    # check would fail against our date-suffixed version string.
                    dontVersionCheck = true;
                    # Skip the meson test suite: the unrelated `SafeSignal copy/move
                    # counter` unit test SIGABRTs under the nix sandbox on this commit.
                    # It has nothing to do with the IPC/workspace fix we're pinning for.
                    # doCheck=false drops catch2 from inputs, so also turn the tests off
                    # at the meson level (last -Dtests flag wins) to not pull the wrap.
                    doCheck = false;
                    mesonFlags = (old.mesonFlags or [ ]) ++ [ "-Dtests=disabled" ];
                });
            })
        ];
    };

    flake.modules.homeManager.workstation = {
        programs.waybar = {
            enable = true;
            # Run waybar as a systemd user service bound to graphical-session.target.
            # Hyprland runs with systemd.enable, which restarts hyprland-session.target
            # at startup; processes exec'd directly from the autostart hook get killed by
            # that restart, but a managed service is restarted along with the target.
            systemd.enable = true;
            # modules-left is contributed by the window manager module
            # (hyprland adds its workspaces widget)
            settings.mainBar = {
                layer = "top";
                position = "top";
                modules-center = [ "tray" ];
                modules-right = [
                    "mpd"
                    "wireplumber"
                    "custom/spotify"
                    "battery"
                    "disk"
                    "clock"
                ];
                battery = {
                    format = "{capacity}% {icon}";
                    format-icons = ["" "" "" "" ""];
                };
                clock = {
                    format = "{:%a, %d. %b | %H:%M}";
                };
                disk = {
                    format = "{percentage_used}% Used";
                };
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
            };
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

#disk {
    border-bottom: 3px solid @base0E;
}

#wireplumber {
    border-bottom: 3px solid @base09;
}

#mpd {
    border-bottom: 3px solid @base08;
}

            '';
        };
    };
}
