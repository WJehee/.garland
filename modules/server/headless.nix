{
    flake.modules.nixos.server = { pkgs, ... }: {
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
            shell = pkgs.zsh;
            extraGroups = [
                "podman"
            ];
            openssh.authorizedKeys.keys = [
                # Main SSH key
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAV7jskmE1QgWJARUS4VtDMscikpRYVGRHZBEWculRLd wouter@rusty-desktop"
            ];
        };
        nix.settings.trusted-users = [ "admin" ];
        security = {
            sudo.enable = false;
            doas = {
                enable = true;
                extraRules = [{
                    users = [ "admin" ];
                    keepEnv = true;
                    noPass = true;
                }];
            };
        };
    };
}
