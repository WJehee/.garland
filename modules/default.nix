{ pkgs, lib, ... }: {
    imports = [
        ./efi.nix
        ./env.nix
        ./pipewire.nix
        ./window.nix
        ./packages.nix
        ./printing.nix
        ./syncthing.nix
        ./usb_backup.nix
        ./firewall.nix
    ];
    system.stateVersion = "23.05";
    nixpkgs.config = {
        allowUnfree = true;
        permittedInsecurePackages = [
            "electron-25.9.0"           
        ];
    };
    nix.settings.experimental-features = [
        "nix-command"
        "flakes"
    ];
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";

    # Auto cleanup garbage
    nix.gc.automatic = true;
    nix.gc.dates = "weekly";
    nix.gc.options = "--delete-older-than 30d";

    boot.tmp.useTmpfs = true;
    hardware.opengl.enable = true;

    networking.networkmanager.enable = true;
    # Fix for wait-online daemon thing, temporary
    systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
    systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

    services.openssh.enable = true;
    programs.ssh = {
        startAgent = true;
        # TODO: make this look nicer
        # askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
    };
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

    # Zsh
    programs.zsh.enable = true;
    programs.zsh.setOptions = [
        "AUTO_CD"
        "COMPLETE_ALIASES"
    ];
    users.defaultUserShell = pkgs.zsh;

    # Fonts
    fonts.packages = with pkgs; [
        hack-font
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        line-awesome
    ];

    # Hyprland
    nix.settings = {
        substituters = ["https://hyprland.cachix.org"];
        trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    programs.hyprland.enable = true;
}
