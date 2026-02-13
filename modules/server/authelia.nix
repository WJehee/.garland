{ config, ... }: {
    sops.secrets."authelia-jwt-secret" = {};
    sops.secrets."authelia-storage-key" = {};

    services.authelia.instances.main = {
        enable = true;
        secrets.storageEncryptionKeyFile = config.sops.secrets."authelia-storage-key".path;
        secrets.jwtSecretFile = config.sops.secrets."authelia-jwt-secret".path;
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
