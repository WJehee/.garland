{
    flake.modules.nixos.workstation = { ... }: {
        services.geoclue2.enable = true;
    };
}
