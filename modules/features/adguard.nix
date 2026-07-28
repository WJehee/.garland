{
    flake.modules.nixos.adguard = {
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
        # Plain DNS for clients on the LAN
        networking.firewall = {
            allowedTCPPorts = [ 53 ];
            allowedUDPPorts = [ 53 ];
        };
    };
}
