{
    flake.modules.nixos.base = { lib, ... }: {
        # NetworkManager stays in base: the wifi feature and the Pis' static
        # address profiles are NetworkManager connection profiles. VPN
        # tooling (Mullvad, OpenVPN) lives in workstation/vpn.nix.
        networking.networkmanager.enable = true;
        # systemd-resolved on every host. The Mullvad module used to enable
        # it implicitly; the adguard module relies on it, and the servers
        # have always run with it
        services.resolved.enable = true;
        # No static nameservers: hosts use the DHCP-provided DNS (AdGuard
        # on the home network), and the Mullvad daemon takes over DNS
        # whenever the VPN is connected.
        systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
        systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
    };
}
