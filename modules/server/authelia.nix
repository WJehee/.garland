{ ... }: {
    services.authelia.instances.main = {
        enable = true;
        secrets.storageEncryptionKeyFile = "/etc/authelia/storageEncryptionKeyFile";
        secrets.jwtSecretFile = "/etc/authelia/jwtSecretFile";
        settings = {
            theme = "dark";
            default_2fa_method = "totp";
            log.level = "debug";
            server.disable_healthcheck = true;
            access_control = {
                default_policy = "deny";
                rules = [
                    {
                        domain = "wouterjehee.com";
                        policy = "bypass";
                    }

                    {
                        domain = "memoirs.wouterjehee.com";
                        policy = "two_factor";
                        subject = [
                            "user:wouter"
                        ];
                    }
                ];
            };
        };
    };
}
