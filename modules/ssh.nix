{ lib, pkgs, ... }: {
    services.openssh.enable = true;
    programs.ssh = {
        startAgent = true;
        extraConfig = "
            Host hemlock
                Hostname 88.198.175.151
                User admin

            Host ivy
                Hostname 192.168.178.132
                User admin
        ";
    };
}
