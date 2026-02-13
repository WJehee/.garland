{ config, ... }: {
    users.users.lldap = {
        isSystemUser = true;
        group = "lldap";
    };
    users.groups.lldap = { };

    sops.secrets."lldap-jwt-secret".owner = "lldap";
    sops.secrets."lldap-admin-password".owner = "lldap";

    services.lldap = {
        enable = true;
        settings = {
            ldap_base_dn = "dc=wouterjehee,dc=com";
            ldap_user_dn = "admin";
            ldap_user_email = "admin@wouterjehee.com";
            http_url = "http://localhost:17170";
            jwt_secret_file = config.sops.secrets."lldap-jwt-secret".path;
            ldap_user_pass_file = config.sops.secrets."lldap-admin-password".path;
            force_ldap_user_pass_reset = "always";
        };
    };
}
