# lldap, the user directory behind authelia and the mail server, with its web
# UI at ldap.wouterjehee.com.
#
# Secrets, add with `just secrets <host>`:
#   lldap-jwt-secret:     generated, `openssl rand -hex 32`. Signs the login
#                         tokens of the lldap web UI; replacing it only logs
#                         everyone out.
#   lldap-admin-password: the password of the lldap `admin` user, chosen by
#                         you (keep a copy in KeePass, it is the web UI
#                         login). lldap resets the admin password to this
#                         value on every start, so the file is authoritative.
#                         Authelia binds to the directory with the same
#                         secret (modules/server/authelia.nix).
{
    flake.modules.nixos."services/lldap" = { config, ... }: {
        users.users.lldap = {
            isSystemUser = true;
            group = "lldap";
        };
        users.groups.lldap = { };

        sops.secrets."lldap-jwt-secret".owner = "lldap";
        sops.secrets."lldap-admin-password".owner = "lldap";

        services.caddy.virtualHosts."ldap.wouterjehee.com".extraConfig = ''
            route {
                import authelia
                reverse_proxy http://localhost:17170
            }
        '';

        services.lldap = {
            enable = true;
            settings = {
                http_host = "127.0.0.1";
                ldap_host = "127.0.0.1";
                ldap_base_dn = "dc=wouterjehee,dc=com";
                ldap_user_dn = "admin";
                ldap_user_email = "admin@wouterjehee.com";
                http_url = "http://localhost:17170";
                jwt_secret_file = config.sops.secrets."lldap-jwt-secret".path;
                ldap_user_pass_file = config.sops.secrets."lldap-admin-password".path;
                force_ldap_user_pass_reset = "always";
            };
        };
    };
}
