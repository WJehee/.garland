{ pkgs, ... }: {
    services = {
        openssh = {
            enable = true;
            settings = {
                PasswordAuthentication = false;
                KbdInteractiveAuthentication = false;
                PermitRootLogin = "no";
            };
        };
    };
    users.users.admin = {
        isNormalUser = true;
        initialPassword = "changeme";
        shell = pkgs.zsh;
        extraGroups = [
            "docker"
        ];
        openssh.authorizedKeys.keys = [
            # Main SSH key
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAV7jskmE1QgWJARUS4VtDMscikpRYVGRHZBEWculRLd wouter@rusty-desktop"
        ];
    };
    security = {
        sudo.enable = false;
        doas = {
            enable = true;
            extraRules = [{
                users = [ "admin" ];
                keepEnv = true;
                persist = true;
                noPass = false;
            }];
        };
    };
}
