{
    flake.modules.homeManager.workstation = { ... }: {
        services.gammastep = {
            enable = true;
            tray = true;
            provider = "geoclue2" ;
        };
    };
}
