{ pkgs, ... }: {
    stylix = {
        image = ./wallpaper.jpg;
        targets.grub.useImage = true;
        polarity = "dark";
        autoEnable = true;

        fonts = {
            monospace = {
                name = "Hack";
                package = pkgs.hack-font;
            };
        };

        opacity.terminal = 0.8;
        #targets.waybar = {
        #    enableCenterBackColors = true;
        #};
    };
}
