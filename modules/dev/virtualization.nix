{
    flake.modules.nixos.virtualization = { pkgs, ... }: {
        programs.virt-manager.enable = true;
        users.groups.libvirtd.members = [ "wouter" ];
        virtualisation = {
            libvirtd = {
                enable = true;
                qemu.swtpm.enable = true;
            };
            spiceUSBRedirection.enable = true;
        };
        environment.systemPackages = with pkgs; [
            # Uses the podman driver; import nixos.podman alongside this
            minikube
        ];
    };
}
