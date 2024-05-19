{ pkgs, ... }: {
    stylix = {
        polarity = "dark";
        autoEnable = true;

        image = ./wallpaper.jpg;
        targets.grub.useImage = true;

        opacity.terminal = 0.8;
        fonts = {
            monospace = {
                name = "Hack";
                package = pkgs.hack-font;
            };
        };
    };
}
