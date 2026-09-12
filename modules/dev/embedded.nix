{
    flake.modules.nixos."dev/embedded" = { pkgs, ... }: {
        # udev rules so picotool (RP2040/RP2350) and probe-rs (debug probes)
        # can access the devices without root; the toolchains themselves
        # live per-project in devenv.
        services.udev.packages = with pkgs; [
            picotool
            probe-rs-tools
        ];
    };
}
