{ config, ... }: {
    sops.secrets."authentik-secret-key" = {};

    sops.templates."authentik-env" = {
        content = ''
            AUTHENTIK_SECRET_KEY=${config.sops.placeholder."authentik-secret-key"}
        '';
    };

    services.authentik = {
        enable = true;
        environmentFile = config.sops.templates."authentik-env".path;
        settings = {
            disable_startup_analytics = true;
            avatars = "initials";
        };
    };
}
