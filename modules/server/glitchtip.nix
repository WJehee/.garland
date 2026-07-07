{ config, ... }: {
    sops.secrets."glitchtip-secret-key" = { };
    sops.templates."glitchtip.env".content = ''
        SECRET_KEY=${config.sops.placeholder."glitchtip-secret-key"}
    '';

    # No forward_auth: login goes through Authelia via OIDC, and the
    # SDK ingest endpoints (/api/<project>/envelope/) must stay reachable
    # with only a DSN.
    services.caddy.virtualHosts."glitchtip.wouterjehee.com".extraConfig = ''
        reverse_proxy http://localhost:8000
    '';

    services.glitchtip = {
        enable = true;
        environmentFiles = [ config.sops.templates."glitchtip.env".path ];
        settings = {
            GLITCHTIP_DOMAIN = "https://glitchtip.wouterjehee.com";
            EMAIL_URL = "consolemail://";
            DEFAULT_FROM_EMAIL = "glitchtip@wouterjehee.com";
            # Registration is closed (module default), but first login via
            # Authelia may still create an account
            ENABLE_SOCIAL_APPS_USER_REGISTRATION = true;
        };
    };
}
