{
    flake.modules.nixos.adguard = { lib, ... }: {
        # systemd-resolved's stub listener occupies port 53, which blocks
        # AdGuard's wildcard bind; keep resolved for the host itself but let
        # it read upstream servers directly instead of through the stub
        services.resolved.settings.Resolve.DNSStubListener = false;
        environment.etc."resolv.conf".source = lib.mkForce "/run/systemd/resolve/resolv.conf";

        services.adguardhome = {
            enable = true;
            # Web UI on port 3000, initial admin user is created via the
            # onboarding wizard on first visit
            port = 3000;
            openFirewall = true;
            # Settings below are only applied on first start, everything
            # stays editable through the web UI afterwards
            mutableSettings = true;
            settings = {
                dns = {
                    bind_hosts = [ "0.0.0.0" ];
                    upstream_dns = [
                        "https://dns.quad9.net/dns-query"
                        "https://cloudflare-dns.com/dns-query"
                    ];
                    bootstrap_dns = [
                        "9.9.9.9"
                        "1.1.1.1"
                    ];
                };
                filtering = {
                    protection_enabled = true;
                    filtering_enabled = true;
                };
                filters = [
                    {
                        name = "AdGuard DNS filter";
                        url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
                        enabled = true;
                    }
                    {
                        name = "AdAway Default Blocklist";
                        url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
                        enabled = true;
                    }
                ];
            };
        };
        # AdGuard also acts as the network's DHCP server (configured through
        # the web UI, like the rest of the mutable settings); CAP_NET_RAW is
        # needed for its raw DHCP sockets
        services.adguardhome.allowDHCP = true;
        # Plain DNS for clients on the LAN, plus DHCP
        networking.firewall = {
            allowedTCPPorts = [ 53 ];
            allowedUDPPorts = [ 53 67 ];
        };
    };
}
