{ pkgs, ... }: {
    users.users.wouter = {
        isNormalUser = true;
        extraGroups = [
            "docker"
            "wireshark"
            "libvirtd"
            "networkmanager"
            "dialout"
        ];
        shell = pkgs.zsh;
    };
}
