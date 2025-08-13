{ pkgs, ... }: {
    stylix = {
        enable = true;
        autoEnable = true;

        polarity = "dark";
        image = ./wallpaper.jpg;
        targets = {
            grub.useWallpaper = true;
            nixvim.transparentBackground = {
                main = true;
                signColumn = true;
            };
        };
        # iconTheme = {
        #     enable = true;
        #     package = pkgs.papirus-nord;
        #     dark = "polarnight4";
        #     light = "polarnight2";
        # };
        cursor = {
            name = "Bibata-Modern-Ice";
            package = pkgs.bibata-cursors;
            size = 24;
        };
        opacity.terminal = 0.9;
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
                package = pkgs.noto-fonts-emoji;
                name = "Noto Fonts Emoji";
            };
        };
    };
}
