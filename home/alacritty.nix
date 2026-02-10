{ config, ... }: {
    programs.alacritty = {
        enable = true;
        settings.keyboard.bindings = [
            {
                key = "Return";
                mods = "Shift";
                chars = builtins.fromJSON "\"\\u001b\\r\"";
            }
        ];
    };
}
