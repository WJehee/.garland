{ pkgs, ... }: {
    users.users.wouter = {
        isNormalUser = true;
        extraGroups = [
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
