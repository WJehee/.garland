{ inputs, pkgs, ... }: {
    imports = [
        ./sops.nix
        ./env.nix
        ./doas.nix
        ./custom.nix

        ./networking.nix
        ./ssh.nix
        ./tailscale.nix
    ];
    system = {
        stateVersion = "24.11";
        autoUpgrade = {
            enable = true;
            flake = inputs.self.outPath;
            dates = "02:00";
            randomizedDelaySec = "45min";
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
        };
        # Needed for building SD image
        binfmt.emulatedSystems = [ "aarch64-linux" ];
    };

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

    environment.systemPackages = with pkgs; [
        fd                  # improved find
        ripgrep             # Better grep
        tree                # Show tree of files
        psmisc              # Killall, etc.
        patchelf

        # File manipulation
        zip
        unzip
        unrar
        ffmpeg
        imagemagick
        file             

        usbutils            # USB utilities
        fzf                 # Fuzzy finder
        inotify-tools       # Notify-send, etc.
        systemctl-tui       # Systemctl terminal UI
        zenith              # System monitor (top)
        dig                 # DNS lookup
        bat                 # improved cat
    ];
}
