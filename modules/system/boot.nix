{ ... }: {
    boot = {
        loader.grub.enable = true;
        loader.grub.device = "nodev";
        loader.grub.efiSupport = true;
        loader.efi.canTouchEfiVariables = true;
    };
}
