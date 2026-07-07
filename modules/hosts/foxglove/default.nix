# Framework laptop
{ config, ... }: let
    nixos = config.flake.modules.nixos;
    hm = config.flake.modules.homeManager;
in {
    flake.modules.nixos."hosts/foxglove" = {
        imports = [
            ./_hardware-configuration.nix
            nixos.base
            nixos.home-manager
            nixos.workstation
            nixos."disk/luks-lvm"
            nixos."gpu/intel"
            nixos.hacking
            nixos."3d-printing"
            nixos.tailscale
            nixos.music
            nixos.llm
            nixos.cad
            nixos.dev
            nixos.virtualization
        ];

        networking.hostName = "foxglove";
        boot.kernelParams = [ "i915.force_probe=46a6" ];
        stylix.image = ../../../wallpapers/foxglove-landscape.jpg;

        home-manager.users.wouter = {
            imports = [
                hm.workstation
                hm.hyprland
                hm.monitor-workspaces
                hm.shell
                hm.dev
            ];
            # DO NOT CHANGE THIS after first install
            home.stateVersion = "26.11";

            wayland.windowManager.hyprland.settings.monitor = [
                { output = ""; mode = "preferred"; position = "auto"; scale = 1; }
                { output = "desc:BOE NE135A1M-NY1"; mode = "preferred"; position = "auto"; scale = 1.2; }
                { output = "desc:Dell Inc. DELL P2416D 6RC2C5BB08FL"; mode = "preferred"; position = "auto-left"; scale = 1; transform = 1; }
                { output = "desc:Dell Inc. DELL P2720D JV69F9AP02VS"; mode = "preferred"; position = "auto-left"; scale = 1; }
            ];

            monitorWorkspaces.profiles = [
                # Docked: spread workspaces across the external monitors.
                {
                    when = [ "P2720D" "P2416D" ];
                    bands = [
                        { monitor = "P2720D"; from = 1; to = 5; }
                        { monitor = "P2416D"; from = 6; to = 9; extra.layout_opts.orientation = "top"; }
                        { monitor = "BOE"; from = 10; to = 10; }
                    ];
                }
                # Any single external monitor: 1-7 on laptop, 8-10 on external.
                {
                    when = [ "*" ];
                    bands = [
                        { monitor = "BOE"; from = 1; to = 7; }
                        { monitor = "*"; from = 8; to = 10; }
                    ];
                }
                # Undocked: everything on the laptop screen.
                {
                    bands = [ { monitor = "BOE"; from = 1; to = 10; } ];
                }
            ];
            xdg.configFile."hypr/hyprpaper.conf".text = ''
                splash = 0

                wallpaper {
                    monitor = desc:BOE NE135A1M-NY1
                    path = ${../../../wallpapers/foxglove-landscape.jpg}
                    fit_mode = cover
                }

                wallpaper {
                    monitor = desc:Dell Inc. DELL P2416D 6RC2C5BB08FL
                    path = ${../../../wallpapers/foxglove-portrait.jpg}
                    fit_mode = cover
                }

                wallpaper {
                    monitor = desc:Dell Inc. DELL P2720D JV69F9AP02VS
                    path = ${../../../wallpapers/foxglove-landscape.jpg}
                    fit_mode = cover
                }
            '';
        };
    };
}
