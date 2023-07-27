{ inputs, pkgs, ... }: {
    imports = [
        ./boot.nix
        ./env.nix
        ./packages.nix

        ../display
    ];
    # General settings
    system.stateVersion = "23.05";
    nixpkgs.config.allowUnfree = true;
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";
    # Auto cleanup garbage
    nix.gc.automatic = true;
    nix.gc.dates = "weekly";
    nix.gc.options = "--delete-older-than 30d";
    # Services
    services.syncthing = {
        enable = true;
        user = "wouter";
        dataDir = "/home/wouter/";
    };
    networking.networkmanager.enable = true;
    services.printing.enable = true;
    services.openssh.enable = true;
    # Security
    security.pam.services.swaylock = {};
    security.doas.enable = true;
    security.sudo.enable = true;
    security.doas.extraRules = [{
        users = [ "wouter" ];
        keepEnv = true;
        persist = true;
    }];
    # Zsh
    programs.zsh.enable = true;
    programs.zsh.setOptions = [
        "AUTO_CD"
        "COMPLETE_ALIASES"
    ];
    users.defaultUserShell = pkgs.zsh;
    # Users
    users.users.wouter = {
        isNormalUser = true;
        extraGroups = [
            "wheel"
            "docker"
            "wireshark"
        ];
    };
}
