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
            nixos."disk/luks-lvm-span"
            nixos.dev
            nixos."dev/android"
            nixos."dev/embedded"
            nixos.podman
            nixos.playground-key
            nixos."gpu/nvidia"
            nixos.virtualization
            nixos.hacking
            nixos."3d-printing"
            nixos.osint
            nixos.music
            nixos.gaming
            # nixos.backup

            # TODO: re-enable once secrets/wisteria.yaml exists with
            # `anthropic-api-key` and `litellm-master-key` (create it with
            # `just secrets wisteria`; the wisteria key and rule are already
            # in .sops.yaml).
            # nixos.llm
            # nixos.ollama
        ];

        networking.hostName = "wisteria";
        # The two NVMe drives that disk/luks-lvm-span partitions at install
        # time; the first one gets the ESP. Kernel names such as nvme0n1 can
        # swap between boots, so confirm them with `lsblk` in the installer
        # right before running `just remote-install`, or replace them with
        # /dev/disk/by-id paths.
        _module.args.disks = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
        # Without this, grub is installed with --no-nvram: the files land on the
        # ESP but the firmware gets no boot entry, and since grub is not at the
        # removable fallback path either, the disk does not show up in the
        # firmware boot menu at all.
        boot.loader.efi.canTouchEfiVariables = true;
        stylix.image = ../../../wallpapers/wisteria-landscape.jpg;

        home-manager.users.wouter = {
            imports = [
                hm.workstation
                hm.hyprland
                hm.shell
                hm.dev
                hm.gaming
            ];
            # DO NOT CHANGE THIS after first install
            home.stateVersion = "26.11";

            wayland.windowManager.hyprland.settings = {
                monitor = [
                    { output = "DP-2"; mode = "preferred"; position = "0x0"; scale = 1; }
                    { output = "DP-1"; mode = "preferred"; position = "auto-right"; scale = 1; transform = 1; }
                    # { output = "HDMI-A-1"; mode = "preferred"; position = "auto-right"; scale = 1; }
                ];
                workspace_rule = [
                    { workspace = "1"; monitor = "DP-2"; default = true; }
                    { workspace = "2"; monitor = "DP-2"; }
                    { workspace = "3"; monitor = "DP-2"; }
                    { workspace = "4"; monitor = "DP-2"; }
                    { workspace = "5"; monitor = "DP-2"; }

                    { workspace = "6"; monitor = "DP-1"; layout_opts = { orientation = "top"; }; }
                    { workspace = "7"; monitor = "DP-1"; layout_opts = { orientation = "top"; }; }
                    { workspace = "8"; monitor = "DP-1"; layout_opts = { orientation = "top"; }; }

                    { workspace = "9"; monitor = "HDMI-A-1"; }
                    { workspace = "10"; monitor = "HDMI-A-1"; }
                ];
            };
            xdg.configFile."hypr/hyprpaper.conf".text = ''
                splash = 0

                wallpaper {
                    monitor = DP-2
                    path = ${../../../wallpapers/wisteria-landscape.jpg}
                    fit_mode = cover
                }

                wallpaper {
                    monitor = DP-1
                    path = ${../../../wallpapers/wisteria-portrait.jpg}
                    fit_mode = cover
                }

                wallpaper {
                    monitor = HDMI-A-1
                    path = ${../../../wallpapers/wisteria-landscape.jpg}
                    fit_mode = cover
                }
            '';
        };
    };
}
