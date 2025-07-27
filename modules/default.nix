{ pkgs, ... }: {
    imports = [
        ./env.nix
        ./packages.nix
        ./custom.nix
        ./stylix.nix
        ./user.nix
        ./networking.nix
        ./chromium.nix

        ./dev
        ./media
        ./security
    ];
    system.stateVersion = "24.11";
    nixpkgs.config = {
        allowUnfree = true;
        permittedInsecurePackages = [];
        android_sdk.accept_license = true;
    };
    programs.nix-ld.enable = true;
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
        kernelPackages = pkgs.linuxPackages_latest;
        tmp.useTmpfs = true;
        loader = {
            grub.enable = true;
            grub.device = "nodev";
            grub.efiSupport = true;
            efi.canTouchEfiVariables = true;
            grub.useOSProber = true;
        };
    };
    programs.kdeconnect.enable = true;
    services.pcscd.enable = true;
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;
    programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-gtk2;
    };
}
