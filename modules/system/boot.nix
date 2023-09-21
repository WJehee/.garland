{ ... }: {
    boot.loader = {
        grub.enable = true;
        grub.device = "nodev";
        grub.efiSupport = true;
        grub.useOSProber = true;
        efi.canTouchEfiVariables = true;
    };
}
