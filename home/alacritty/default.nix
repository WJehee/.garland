{ config, ... }: {
    programs.alacritty = {
        enable = true;
        settings = {
            window.opacity = 0.9;
            colors = {
                draw_bold_text_with_bright_colors = false;
                primary = {
                    background = "#${config.colorScheme.colors.base00}"; 
                    foreground = "#${config.colorScheme.colors.base05}";
                };
                cursor = {
                    text = "#${config.colorScheme.colors.base00}";
                    cursor = "#${config.colorScheme.colors.base05}";
                };
                normal = {
                    black = "#${config.colorScheme.colors.base00}";
                    red = "#${config.colorScheme.colors.base08}";
                    green = "#${config.colorScheme.colors.base0B}";
                    yellow = "#${config.colorScheme.colors.base0A}";
                    blue = "#${config.colorScheme.colors.base0D}";
                    magenta = "#${config.colorScheme.colors.base0E}";
                    cyan = "#${config.colorScheme.colors.base0C}";
                    white = "#${config.colorScheme.colors.base05}";
                };
                bright = {
                    black = "#${config.colorScheme.colors.base03}";
                    red = "#${config.colorScheme.colors.base08}";
                    green = "#${config.colorScheme.colors.base0B}";
                    yellow = "#${config.colorScheme.colors.base0A}";
                    blue = "#${config.colorScheme.colors.base0D}";
                    magenta = "#${config.colorScheme.colors.base0E}";
                    cyan = "#${config.colorScheme.colors.base0C}";
                    white = "#${config.colorScheme.colors.base07}";
                };
            };
        };
    };
}
