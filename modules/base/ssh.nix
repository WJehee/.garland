{
    flake.modules.nixos.base = { ... }: {
        services.openssh.enable = true;
        programs.ssh = {
            startAgent = true;
            extraConfig = "
            Host hemlock
                Hostname 88.198.175.151
                User admin

            Host ivy
                Hostname 192.168.178.43
                User admin

            Host wormwood
                Hostname 192.168.178.44
                User admin
        ";
        };
    };
}
