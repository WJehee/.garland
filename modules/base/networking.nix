{
    flake.modules.nixos.base = { lib, pkgs, ... }: {
        networking = {
            networkmanager = {
                enable = true;
                plugins = with pkgs; [
                    networkmanager-openvpn
                ];
            };
            # No static nameservers: hosts use the DHCP-provided DNS (AdGuard
            # on the home network), and the Mullvad daemon takes over DNS
            # whenever the VPN is connected.
        };
        services.mullvad-vpn.enable = true;
        environment.systemPackages = with pkgs; [
            openvpn
        ];
        systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
        systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
    };
}
