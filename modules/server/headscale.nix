{
    flake.modules.nixos."services/headscale" = {
        services.headscale = {
            enable = true;
        };
    };
}
