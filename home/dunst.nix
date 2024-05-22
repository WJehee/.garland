{ ... }: {
    services.dunst = {
        enable = true;    
        settings = {
            global = {
                monitor = 2;
            };
        };
    };
}
