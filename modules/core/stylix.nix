{ pkgs, hostname, vars, ... }: {
    stylix = {
        enable = true;
        autoEnable = false;

        base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
        polarity = "dark";
        image = vars.garland.wallpaper.landscape or ../../wallpapers/${hostname}-landscape.jpg;
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
}
