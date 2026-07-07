# System and home stylix in one place
{ inputs, ... }: {
    flake.modules.nixos.workstation = { pkgs, lib, ... }: {
        imports = [ inputs.stylix.nixosModules.stylix ];
        stylix = {
            enable = true;
            autoEnable = false;

            base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
            polarity = "dark";
            # Hosts set their own wallpaper on top of this fallback
            image = lib.mkDefault ../../wallpapers/default.jpg;
            targets = {
                plymouth.enable = true;
                grub = {
                    enable = true;
                    useWallpaper = true;
                };
                nixvim = {
                    enable = true;
                    transparentBackground = {
                        main = false;
                        signColumn = false;
                    };
                };

            };
            cursor = {
                name = "Bibata-Modern-Ice";
                package = pkgs.bibata-cursors;
                size = 24;
            };
            fonts = {
                sansSerif = {
                    package = pkgs.geist-font;
                    name = "Geist";
                };
                monospace = {
                    package = pkgs.nerd-fonts.geist-mono;
                    name = "Geist Mono";
                };
                emoji = {
                    package = pkgs.noto-fonts-color-emoji;
                    name = "Noto Fonts Emoji";
                };
            };
        };
    };

    flake.modules.homeManager.workstation = { lib, ... }: {
        stylix = {
            enable = true;
            autoEnable = true;
            targets = {
                hyprpaper.enable = lib.mkForce false;
                librewolf.profileNames = [ "default" ];
            };
            opacity.terminal = 0.95;
        };
    };
}
