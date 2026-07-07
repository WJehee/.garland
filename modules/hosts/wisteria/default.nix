# Desktop computer
{ config, ... }: let
    nixos = config.flake.modules.nixos;
    hm = config.flake.modules.homeManager;
in {
    flake.modules.nixos."hosts/wisteria" = {
        imports = [
            ./_hardware-configuration.nix
            nixos.base
            nixos.home-manager
            nixos.workstation
            nixos."gpu/amd"
            nixos.osint
            nixos.music
        ];

        networking.hostName = "wisteria";
        boot.initrd.luks.devices.nixos = {
            device = "/dev/disk/by-uuid/79f8374d-c878-442c-acd0-88f474dda0d6";
            preLVM = true;
        };
        stylix.image = ../../../wallpapers/wisteria-landscape.jpg;

        home-manager.users.wouter = {
            imports = [
                hm.workstation
                hm.hyprland
                hm.shell
                hm.dev
            ];
            # DO NOT CHANGE THIS after first install
            home.stateVersion = "26.11";

            wayland.windowManager.hyprland.settings = {
                monitor = [
                    { output = "DP-3"; mode = "preferred"; position = "0x0"; scale = 1; }
                    { output = "DP-2"; mode = "preferred"; position = "auto-right"; scale = 1; transform = 1; }
                    { output = "HDMI-A-1"; mode = "preferred"; position = "auto-right"; scale = 1; }
                ];
                workspace_rule = [
                    { workspace = "1"; monitor = "DP-3"; default = true; }
                    { workspace = "2"; monitor = "DP-3"; }
                    { workspace = "3"; monitor = "DP-3"; }
                    { workspace = "4"; monitor = "DP-3"; }
                    { workspace = "5"; monitor = "DP-3"; }

                    { workspace = "6"; monitor = "DP-2"; layout_opts = { orientation = "top"; }; }
                    { workspace = "7"; monitor = "DP-2"; layout_opts = { orientation = "top"; }; }
                    { workspace = "8"; monitor = "DP-2"; layout_opts = { orientation = "top"; }; }

                    { workspace = "9"; monitor = "HDMI-A-1"; }
                    { workspace = "10"; monitor = "HDMI-A-1"; }
                ];
            };
            xdg.configFile."hypr/hyprpaper.conf".text = ''
                splash = false
                preload = ~/.garland/wallpapers/wisteria-landscape.jpg
                preload = ~/.garland/wallpapers/wisteria-portrait.jpg

                wallpaper = DP-3, ~/.garland/wallpapers/wisteria-landscape.jpg
                wallpaper = DP-2, ~/.garland/wallpapers/wisteria-portrait.jpg
                wallpaper = HDMI-A-1, ~/.garland/wallpapers/wisteria-landscape.jpg
            '';
        };
    };
}
