{
    flake.modules.nixos.gaming = {
        programs = {
            steam = {
                enable = true;
                gamescopeSession.enable = true;
            };
            gamemode.enable = true;
        };
    };
}
