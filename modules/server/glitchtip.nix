{
    flake.modules.nixos."services/glitchtip" = { config, lib, pkgs, ... }: {
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

        # The glitchtip-manage wrapper from nixpkgs hardcodes
        # ${security.wrapperDir}/sudo, which does not exist with doas
        # (and doas-sudo-shim does not support the -E flag it passes).
        # Replace it with a doas equivalent; run as root: doas glitchtip-manage ...
        environment.systemPackages =
            let
                cfg = config.services.glitchtip;
                env = lib.mapAttrs (
                    _: value:
                    if value == true then "True"
                    else if value == false then "False"
                    else toString value
                ) cfg.settings;
            in [
                (lib.hiPrio (pkgs.writeShellScriptBin "glitchtip-manage" ''
                    set -o allexport
                    ${lib.toShellVars env}
                    ${lib.concatMapStringsSep "\n" (f: "source ${f}") cfg.environmentFiles}
                    exec /run/wrappers/bin/doas -u ${cfg.user} ${lib.getExe cfg.package} "$@"
                ''))
            ];

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
    };
}
