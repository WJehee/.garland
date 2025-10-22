{ ... }: {
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = [ "wouter" ];
    virtualisation = {
        libvirtd = {
            enable = true;
            qemu.swtpm.enable = true;
        };
        spiceUSBRedirection.enable = true;
    };
}
