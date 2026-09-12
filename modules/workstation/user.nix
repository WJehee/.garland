{
    flake.modules.nixos.workstation = { pkgs, ... }: {
        users.users.wouter = {
            isNormalUser = true;
            uid = 1000;
            extraGroups = [
                "avahi"
                "podman"
                "wireshark"
                "libvirtd"
                "networkmanager"
                "dialout"
                "scanner"
                "lp"
                "lpadmin"
            ];
            shell = pkgs.zsh;
        };
        # deploy-rs remote builds pass --store ssh-ng://... to the local
        # daemon, which only accepts that setting from trusted users.
        nix.settings.trusted-users = [ "wouter" ];
        security.doas.extraRules = [{
            users = [ "wouter" ];
            keepEnv = true;
            noPass = true;
        }];
    };
}
