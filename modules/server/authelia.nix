{
    flake.modules.nixos."services/authelia" = { config, ... }: {
        sops.secrets = {
            "authelia-jwt-secret".owner = "authelia-main";
            "authelia-storage-encryption-key".owner = "authelia-main";
            "authelia-session-secret".owner = "authelia-main";
            "authelia-oidc-hmac-secret".owner = "authelia-main";
            "authelia-oidc-issuer-private-key".owner = "authelia-main";
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
                oidcHmacSecretFile = config.sops.secrets."authelia-oidc-hmac-secret".path;
                oidcIssuerPrivateKeyFile = config.sops.secrets."authelia-oidc-issuer-private-key".path;
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
                            policy = "two_factor";
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
                identity_providers = {
                    oidc = {
                        clients = [
                            {
                                client_id = "glitchtip";
                                client_name = "GlitchTip";
                                # plaintext is in sops: glitchtip-oidc-client-secret
                                client_secret = "$pbkdf2-sha512$310000$tpQ6n.ozcfZf2sb4mIPt2Q$BcHbMzOG3tKCPWExCHjzHevAsz1x50GsLkEKGYK4D6qy7b3UMzvKU7.z39LN8wdS.QUDPDrP5iTgiKvuFjq2mg";
                                public = false;
                                authorization_policy = "one_factor";
                                require_pkce = false;
                                redirect_uris = [
                                    "https://glitchtip.wouterjehee.com/accounts/oidc/authelia/login/callback/"
                                    "https://glitchtip.wouterjehee.com/accounts/authelia/login/callback/"
                                ];
                                scopes = [ "openid" "email" "profile" ];
                                response_types = [ "code" ];
                                grant_types = [ "authorization_code" ];
                                token_endpoint_auth_method = "client_secret_basic";
                            }
                        ];
                    };
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
