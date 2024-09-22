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
        };
        opacity.terminal = 0.9;
    };
    fonts.packages = with pkgs; [
        (nerdfonts.override { fonts = ["Hack"]; })
    ];
}
