{ ... }: {
    services.syncthing = {
        enable = true;
        user = "wouter";
        dataDir = "/home/wouter";
        configDir = "/home/wouter/.config/syncthing";
    };
}
