{
    flake.modules.nixos.workstation = { lib, pkgs, ... }: {
        # English language (LANG / LC_MESSAGES stay en_US from base), Dutch
        # regional conventions: euro, decimal comma, A4, metric. Time is the
        # one category that also carries day and month names, so it uses
        # en_GB: Monday week start, 24 hour clock, day-month-year, English
        # names. Keyboard layout is separate (hyprland kb_layout = us).
        i18n.extraLocaleSettings = let nl = "nl_NL.UTF-8"; in {
            LC_TIME = "en_GB.UTF-8";
            LC_NUMERIC = nl;
            LC_MONETARY = nl;
            LC_PAPER = nl;
            LC_MEASUREMENT = nl;
            LC_ADDRESS = nl;
            LC_TELEPHONE = nl;
            LC_NAME = nl;
            LC_IDENTIFICATION = nl;
        };

        # Run unpatched dynamically linked binaries (pip wheels, downloaded
        # tools); dev convenience, not wanted on servers
        programs.nix-ld.enable = true;
        # aarch64 emulation for building the Raspberry PI SD images here
        boot.binfmt.emulatedSystems = lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [ "aarch64-linux" ];
        nix.settings.extra-platforms = [ "aarch64-linux" ];
    };
}
