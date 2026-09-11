# Stub host: base + server (headless), no role yet. Fill in hardware, disk layout and
# features when the machine gets a job. `just remote-install belladonna <conn_str>`
# generates the real hardware configuration.
{ config, ... }: {
    flake.modules.nixos."hosts/belladonna" = { lib, ... }: {
        imports = [
            config.flake.modules.nixos.base
            config.flake.modules.nixos.server
        ];

        networking.hostName = "belladonna";
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        # DO NOT CHANGE THIS after first install
        # mkForce: the base module pins 24.11 for the older hosts, but a
        # fresh install should start at the release it was installed with
        system.stateVersion = lib.mkForce "26.11";

        # Placeholders so the flake evaluates before first install
        fileSystems."/" = {
            device = "/dev/disk/by-label/nixos";
            fsType = "ext4";
        };
        boot.loader.grub = {
            enable = true;
            devices = [];
            efiSupport = true;
            efiInstallAsRemovable = true;
        };
    };
}
