{ ... }: {
    security.pam.services.swaylock = {};
    security.sudo.enable = false;
    security.doas.enable = true;
    security.doas.extraRules = [{
        users = [ "wouter" ];
        keepEnv = true;
        noPass = true;
    }];
}
