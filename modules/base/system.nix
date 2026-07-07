{
    flake.modules.nixos.base = { pkgs, lib, ... }: {
        system = {
            # DO NOT CHANGE THIS after first install
            stateVersion = "24.11";
            autoUpgrade = {
                enable = true;
                # Pull from the remote: inputs.self.outPath is a frozen store
                # snapshot, so upgrading from it never picks up new commits
                flake = "github:WJehee/.garland";
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
            # Needed for building SD image, not on the PI itself
            binfmt.emulatedSystems = lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [ "aarch64-linux" ];
        };

        nixpkgs.config = {
            allowUnfree = true;
            permittedInsecurePackages = [];
            # TODO: temporary fix -- remove this allowInsecurePredicate once nixpkgs
            # resumes maintaining librewolf and drops the insecure mark.
            #
            # nixpkgs marks every librewolf variant insecure -- not for a CVE, but
            # because the packaging lost its maintainer ("lacks maintenance in
            # nixpkgs"). librewolf-bin ships the official upstream binaries, which
            # LibreWolf still patches, so the browser itself stays current. Allow it
            # by name (not the versioned string) so `just update` doesn't reintroduce
            # the eval error every time the version bumps.
            allowInsecurePredicate = pkg:
                builtins.elem (lib.getName pkg) [ "librewolf-bin" "librewolf-bin-unwrapped" ];
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

            jq                  # JSON parsing
            usbutils            # USB utilities
            fzf                 # Fuzzy finder
            inotify-tools       # Notify-send, etc.
            systemctl-tui       # Systemctl terminal UI
            zenith              # System monitor (top)
            dig                 # DNS lookup
            bat                 # improved cat

            git
            jujutsu
            just
            nushellPlugins.query
        ];
    };
}
