{ config, ... }: {
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
}
