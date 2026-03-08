{ ... }: {
    services.dunst = {
        enable = true;    
        settings = {
            global = {
                monitor = 2;
                origin = "bottom-right";
                offset = "30x75";
            };
        };
    };
}
