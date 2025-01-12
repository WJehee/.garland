{ pkgs, ... }: {
    stylix = {
        enable = true;
        autoEnable = true;

        polarity = "dark";
        image = ./wallpaper.jpg;
        targets = {
            grub.useImage = true;
            nixvim.transparentBackground = {
                main = true;
                signColumn = true;
            };
            spicetify.enable = false;
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
