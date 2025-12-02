{ lib, pkgs, ... }: {
    services.openssh.enable = true;
    programs.ssh = {
        startAgent = true;
        extraConfig = "
            Host hemlock
                Hostname wouterjehee.com
                User admin

            Host ivy
                Hostname 192.168.178.132
                User admin
        ";
    };
}
