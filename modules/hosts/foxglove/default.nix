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
            nixos.dj
            nixos.dev
            nixos."dev/android"
            nixos."dev/embedded"
            nixos.podman
            nixos.virtualization

            # nixos.backup
        ];

        networking.hostName = "foxglove";
        boot.kernelParams = [ "i915.force_probe=46a6" ];

        # Don't suspend when charging and lid is closed
        services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

        # Framework publishes BIOS and EC updates on LVFS; fwupd stages the UEFI
        # capsule on the ESP and the firmware applies it on the next boot.
        services.fwupd.enable = true;
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
                # Desk layout, left to right: P2720D (landscape), P2416D
                # (portrait), laptop panel. The positions are explicit because
                # `auto-left` places monitors in the order they are detected,
                # not in rule order: whenever the dock enumerated the P2720D
                # first, the portrait P2416D ended up on the far left instead
                # of in the middle.
                #
                # Logical sizes the coordinates are derived from; the x offsets
                # must be recomputed if a mode, scale or transform changes:
                #   P2720D 2560x1440, P2416D 1440x2560 (2560x1440 rotated),
                #   BOE 2400x1600 (2880x1920 at scale 1.2).
                # Vertically the P2720D is centred on the portrait screen
                # ((2560 - 1440) / 2 = 560) and the laptop is bottom-aligned
                # with it (2560 - 1600 = 960).
                { output = "desc:Dell Inc. DELL P2720D JV69F9AP02VS"; mode = "preferred"; position = "0x560"; scale = 1; }
                { output = "desc:Dell Inc. DELL P2416D 6RC2C5BB08FL"; mode = "preferred"; position = "2560x0"; scale = 1; transform = 1; }
                { output = "desc:BOE NE135A1M-NY1"; mode = "preferred"; position = "4000x960"; scale = 1.2; }
            ];

            # A static desc-pinned rule set cannot express these layouts: rules
            # bound to a disconnected monitor still count as taken (a new
            # monitor grabs the next unruled workspace, here 11+), and there is
            # no wildcard for "whatever monitor just got plugged in".
            monitorWorkspaces.profiles = [
                # Docked: internal panel off, workspaces on the external
                # monitors only. `extra.default = false` keeps workspace 1 the
                # sole default of P2720D.
                {
                    when = [ "P2720D" "P2416D" ];
                    disable = [ "BOE" ];
                    bands = [
                        { monitor = "P2720D"; from = 1; to = 5; }
                        { monitor = "P2416D"; from = 6; to = 9; extra.layout_opts.orientation = "top"; }
                        { monitor = "P2720D"; from = 10; to = 10; extra.default = false; }
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
