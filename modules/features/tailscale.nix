{
    flake.modules.nixos.tailscale = {
        services.tailscale = {
            enable = true;
            openFirewall = true;
        };
        # openFirewall only opens tailscale's own UDP port; traffic arriving
        # over the tailnet is still filtered without this.
        networking.firewall.trustedInterfaces = [ "tailscale0" ];
    };
}
