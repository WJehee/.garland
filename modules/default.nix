{ pkgs, ... }: {
    imports = [
        ./env.nix
        ./packages.nix
        ./custom.nix
        ./user.nix
        ./networking.nix
        ./chromium.nix
        ./bluetooth.nix
        ./stylix.nix
        ./geoclue.nix
        ./virtualization.nix

        ./dev
        ./media
        ./security
    ];
    system.stateVersion = "24.11";
    nixpkgs.config = {
        allowUnfree = true;
        permittedInsecurePackages = [];
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
            extra-platforms = [ "aarch64-linux" ];
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
            grub = {
                enable = true;
                device = "nodev";
                efiSupport = true;
                configurationLimit = 5;
                useOSProber = true;
            };
            efi.canTouchEfiVariables = true;
        };
        # Needed for building SD image
        binfmt.emulatedSystems = [ "aarch64-linux" ];
    };
    services.pcscd.enable = true;
    programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-gtk2;
    };
}
