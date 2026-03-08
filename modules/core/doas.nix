{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [ doas-sudo-shim ];
    security = {
        sudo.enable = false;
        doas.enable = true;
        doas.extraRules = [{
            users = [ "wouter" ];
            keepEnv = true;
            noPass = true;
        }];
    };
}
