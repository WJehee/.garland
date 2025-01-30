{ lib, ... }: {
    networking = {
        networkmanager.enable = true;
        nameservers = [ "9.9.9.9" ];
    };
    systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
    systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
}
