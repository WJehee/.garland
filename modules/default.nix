{ pkgs, lib, ... }: {
    imports = [
        ./efi.nix
        ./env.nix
        ./pipewire.nix
        ./graphics.nix
        ./packages.nix
        ./printing.nix
        ./syncthing.nix
        ./starship.nix
        ./usb_backup.nix
        ./firewall.nix
        ./stylix.nix

        # ./music.nix
        # ./gaming.nix
    ];
    system.stateVersion = "23.05";
    nixpkgs.config = {
        allowUnfree = true;
        permittedInsecurePackages = [
        ];
    };
    nix.settings = {
        use-xdg-base-directories = true;
        experimental-features = [
            "nix-command"
            "flakes"
        ];
    };
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";

    # Auto cleanup garbage
    nix.gc.automatic = true;
    nix.gc.dates = "weekly";
    nix.gc.options = "--delete-older-than 30d";

    boot.tmp.useTmpfs = true;

    networking.networkmanager.enable = true;
    systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
    systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

    services.openssh.enable = true;
    programs.ssh.startAgent = true;
    security.pam.services.swaylock = {};
    security.sudo.enable = false;
    security.doas.enable = true;
    security.doas.extraRules = [{
        users = [ "wouter" ];
        keepEnv = true;
        noPass = true;
    }];
    users.users.wouter = {
        isNormalUser = true;
        extraGroups = [
            "docker"
            "wireshark"
            "libvirtd"
            "networkmanager"
        ];
    };

    programs.zsh = {
        enable = true;
        setOptions = [
            "AUTO_CD"
            "COMPLETE_ALIASES"
        ];
    };
    users.defaultUserShell = pkgs.zsh;

    nix.settings = {
        substituters = ["https://hyprland.cachix.org"];
        trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    programs.hyprland.enable = true;

    services.tailscale.enable = true;
    programs.git.config.safe.directory = [
        "/home/wouter/.dotfiles-nix/.git"
        "/home/admin/.dotfiles-nix/.git"
    ];
}
