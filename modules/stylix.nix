{ pkgs, ... }: {
    stylix = {
        enable = true;
        autoEnable = true;

        polarity = "dark";
        image = ./wallpaper.jpg;
        targets = {
            grub.useImage = true;
            nixvim.transparent_bg = {
                main = true;
                sign_column = true;
            };
        };

        fonts = {
            monospace = {
                name = "Hack";
                package = pkgs.hack-font;
            };
        };
        opacity.terminal = 0.9;
    };
}
