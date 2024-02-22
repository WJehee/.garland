{ config, ... }: {
    programs.alacritty = {
        enable = true;
        settings = {
            window.opacity = 0.9;
            colors = {
                draw_bold_text_with_bright_colors = false;
                primary = {
                    background = "#${config.colorScheme.palette.base00}"; 
                    foreground = "#${config.colorScheme.palette.base05}";
                };
                cursor = {
                    text = "#${config.colorScheme.palette.base00}";
                    cursor = "#${config.colorScheme.palette.base05}";
                };
                normal = {
                    black = "#${config.colorScheme.palette.base00}";
                    red = "#${config.colorScheme.palette.base08}";
                    green = "#${config.colorScheme.palette.base0B}";
                    yellow = "#${config.colorScheme.palette.base0A}";
                    blue = "#${config.colorScheme.palette.base0D}";
                    magenta = "#${config.colorScheme.palette.base0E}";
                    cyan = "#${config.colorScheme.palette.base0C}";
                    white = "#${config.colorScheme.palette.base05}";
                };
                bright = {
                    black = "#${config.colorScheme.palette.base03}";
                    red = "#${config.colorScheme.palette.base08}";
                    green = "#${config.colorScheme.palette.base0B}";
                    yellow = "#${config.colorScheme.palette.base0A}";
                    blue = "#${config.colorScheme.palette.base0D}";
                    magenta = "#${config.colorScheme.palette.base0E}";
                    cyan = "#${config.colorScheme.palette.base0C}";
                    white = "#${config.colorScheme.palette.base07}";
                };
            };
        };
    };
}
