{ pkgs, lib, ... }: {
    imports = [
        ./env.nix
        ./packages.nix
        ./stylix.nix
        ./user.nix

        ./dev
        ./media
        ./security
    ];
    system.stateVersion = "24.11";
    nixpkgs.config = {
        allowUnfree = true;
        permittedInsecurePackages = [];
    };
    nix = {
        settings = {
            use-xdg-base-directories = true;
            experimental-features = [
                "nix-command"
                "flakes"
            ];
            substituters = ["https://hyprland.cachix.org"];
            trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
        };
        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
        };
    };
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";

    boot = {
        tmp.useTmpfs = true;
        loader = {
            grub.enable = true;
            grub.device = "nodev";
            grub.efiSupport = true;
            efi.canTouchEfiVariables = true;
            # grub.useOSProber = true;
        };
    };
    networking.networkmanager.enable = true;
    systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
    systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

    programs.kdeconnect.enable = true;
}
