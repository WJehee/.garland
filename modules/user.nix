{ pkgs, ... }: {
    users.users.wouter = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = [
            "avahi"
            "docker"
            "wireshark"
            "libvirtd"
            "networkmanager"
            "dialout"
            "scanner"
            "lp"
            "lpadmin"
        ];
        shell = pkgs.zsh;
    };
}
