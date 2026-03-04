{ pkgs, hostname, ... }: {
    stylix = {
        enable = true;
        autoEnable = true;

        base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
        polarity = "dark";
        image = ../wallpapers/default.jpg;
        targets = {
            grub.useWallpaper = true;
            nixvim.transparentBackground = {
                main = false;
                signColumn = false;
            };
        };
        cursor = {
            name = "Bibata-Modern-Ice";
            package = pkgs.bibata-cursors;
            size = 24;
        };
        opacity.terminal = 0.95;
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
