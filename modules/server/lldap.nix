{ config, ... }: {
    sops.secrets."lldap-jwt-secret" = {};
    sops.secrets."lldap-admin-password" = {};

    sops.templates."lldap-env" = {
        content = ''
            LLDAP_JWT_SECRET=${config.sops.placeholder."lldap-jwt-secret"}
            LLDAP_LDAP_USER_PASS=${config.sops.placeholder."lldap-admin-password"}
        '';
    };

    services.lldap = {
        enable = true;
        environmentFile = config.sops.templates."lldap-env".path;
        settings = {
            ldap_base_dn = "dc=wouterjehee,dc=com";
            ldap_user_dn = "admin";
            ldap_user_email = "admin@wouterjehee.com";
            http_url = "http://localhost:17170";
        };
    };
}
