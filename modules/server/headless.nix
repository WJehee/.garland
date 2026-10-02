{
    flake.modules.nixos.server = { pkgs, ... }: let
        keys = import ../_ssh-keys.nix;
    in {
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
                keys.nitrokey
                keys.nitrokey-backup
                # Software key kept as a fallback for when the token is not at hand
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
