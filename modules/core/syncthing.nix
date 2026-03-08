{ ... }: {
    services.syncthing = {
        enable = true;
        user = "wouter";
        dataDir = "/home/wouter/Sync";
        configDir = "/home/wouter/.config/syncthing";
    };
}
