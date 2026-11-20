# Authelia, the single sign-on portal that caddy consults (the `authelia`
# snippet) before proxying to protected sites. Users come from lldap.
#
# Secrets, add with `just secrets <host>`. All three are generated, each
# with its own `openssl rand -hex 32`:
#   authelia-jwt-secret:             signs the links in identity verification
#                                    and password reset mails.
#   authelia-storage-encryption-key: encrypts sensitive columns of the
#                                    database (TOTP secrets and the like).
#                                    Never replace it: the existing database
#                                    becomes unreadable.
#   authelia-session-secret:         encrypts session data; replacing it only
#                                    logs everyone out.
#
# This module also reads `lldap-admin-password`, which is declared and
# described in modules/server/lldap.nix, so a host importing authelia must
# import lldap as well.
{
    flake.modules.nixos."services/authelia" = { config, ... }: {
        sops.secrets = {
            "authelia-jwt-secret".owner = "authelia-main";
            "authelia-storage-encryption-key".owner = "authelia-main";
            "authelia-session-secret".owner = "authelia-main";
        };

        sops.templates."authelia-ldap-password.yml" = {
            owner = "authelia-main";
            content = builtins.toJSON {
                authentication_backend.ldap.password = config.sops.placeholder."lldap-admin-password";
            };
        };

        services.caddy = {
            extraConfig = ''
                (authelia) {
                    forward_auth localhost:9091 {
                        uri /api/authz/forward-auth
                        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
                    }
                }
            '';
            virtualHosts = {
                "auth.wouterjehee.com".extraConfig = ''
                    reverse_proxy http://localhost:9091
                '';
                "auth.dorusrijkers.eu".extraConfig = ''
                    reverse_proxy http://localhost:9091
                '';
            };
        };

        services.authelia.instances.main = {
            enable = true;
            secrets = {
                jwtSecretFile = config.sops.secrets."authelia-jwt-secret".path;
                storageEncryptionKeyFile = config.sops.secrets."authelia-storage-encryption-key".path;
                sessionSecretFile = config.sops.secrets."authelia-session-secret".path;
            };
            settingsFiles = [
                config.sops.templates."authelia-ldap-password.yml".path
            ];
            settings = {
                server = {
                    address = "tcp://127.0.0.1:9091/";
                };
                authentication_backend = {
                    ldap = {
                        implementation = "lldap";
                        address = "ldap://localhost:3890";
                        base_dn = "dc=wouterjehee,dc=com";
                        user = "uid=admin,ou=people,dc=wouterjehee,dc=com";
                    };
                };
                storage = {
                    local = {
                        path = "/var/lib/authelia-main/db.sqlite3";
                    };
                };
                session = {
                    cookies = [
                        {
                            domain = "wouterjehee.com";
                            authelia_url = "https://auth.wouterjehee.com";
                        }
                        {
                            domain = "dorusrijkers.eu";
                            authelia_url = "https://auth.dorusrijkers.eu";
                        }
                    ];
                };
                access_control = {
                    default_policy = "deny";
                    rules = [
                        # NOTE: order for rules matter, first that matches is applied
                        {
                            domain = "ldap.wouterjehee.com";
                            policy = "two_factor";
                            subject = [ "group:lldap_admin" ];
                        }
                        # Public board display - no auth needed
                        {
                            domain = "6767ov.dorusrijkers.eu";
                            policy = "bypass";
                            resources = [
                                "^/$"
                                "^/ws$"
                                "^/static/.*"
                                "^/sounds/.*"
                            ];
                        }
                        # Protected admin area
                        {
                            domain = "6767ov.dorusrijkers.eu";
                            policy = "one_factor";
                            resources = [
                                "^/admin/.*"
                                "^/api/departures.*"
                                "^/api/speak$"
                            ];
                        }
                        {
                            domain = "*.wouterjehee.com";
                            policy = "one_factor";
                        }
                        {
                            domain = "*.dorusrijkers.eu";
                            policy = "one_factor";
                        }
                    ];
                };
                notifier = {
                    filesystem = {
                        filename = "/var/lib/authelia-main/notification.txt";
                    };
                };
                totp = {
                    issuer = "wouterjehee.com";
                };
            };
        };
    };
}
