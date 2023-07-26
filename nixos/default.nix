{ inputs, outputs, pkgs, ... }:
{
    imports = [
        inputs.home-manager.nixosModules.home-manager
        ./hardware-configuration.nix
        ./boot.nix
        ./env.nix
        ./display.nix
        ./dev.nix
    ];
    # General settings
    system.stateVersion = "23.05";
    nixpkgs.config.allowUnfree = true;
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";

    networking.hostName = "rusty-nix";
    networking.networkmanager.enable = true;

    # Auto cleanup garbage
    nix.gc.automatic = true;
    nix.gc.dates = "weekly";
    nix.gc.options = "--delete-older-than 30d";

    environment.systemPackages = [
        pkgs.gcc
        pkgs.wl-clipboard
        pkgs.cliphist
        pkgs.signal-desktop
        pkgs.obsidian
        pkgs.flavours
    ];
    services.syncthing = {
        enable = true;
        user = "wouter";
        dataDir = "/home/wouter/";
    };
    services.printing.enable = true;
    services.openssh.enable = true;

    security.pam.services.swaylock = {};
    security.doas.enable = true;
    security.sudo.enable = true;
    security.doas.extraRules = [{
        users = [ "wouter" ];
        keepEnv = true;
        persist = true;
    }];

    programs.zsh.enable = true;
    programs.zsh.setOptions = [
        "AUTO_CD"
        "COMPLETE_ALIASES"
    ];
    users.defaultUserShell = pkgs.zsh;
    users.users.wouter = {
        isNormalUser = true;
        extraGroups = [
            "wheel"
            "docker"
            "wireshark"
        ];
        packages = with pkgs; [
            alacritty
            firefox
            wofi
            grim
            syncthing
            keepassxc
            dunst
            bspwm
            git
            docker
        ];
    };
    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        users.wouter = import ../home-manager/home.nix;
    };
}
