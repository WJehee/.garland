# Subnet router: advertises the home LAN to the tailnet so remote nodes can
# reach every device at home, not just this host. Import together with the
# tailscale feature. Access to the LAN is governed by the headscale policy
# (modules/server/headscale.nix); tailscale enforces it on this node for
# every packet it forwards.
{
    flake.modules.nixos.gateway = { config, ... }: {
        # Pre-auth key so the gateway rejoins the tailnet on its own after a
        # reflash. Created on hemlock for the admin user (who owns
        # tag:gateway):
        #   headscale preauthkeys create --user wouter --reusable --expiration 1y
        # and stored with `just secrets <host>`
        sops.secrets."tailscale-authkey" = {
            restartUnits = [ "tailscaled-autoconnect.service" ];
        };
        services.tailscale = {
            # Enables IP forwarding; tailscale masquerades forwarded traffic
            # behind this host's LAN address, so LAN devices need no route
            # back to the tailnet
            useRoutingFeatures = "server";
            extraUpFlags = [
                "--advertise-routes=192.168.178.0/24"
                # tag:gateway makes the policy's autoApprovers accept the
                # route without manual approval
                "--advertise-tags=tag:gateway"
                # This host is the DNS server headscale hands out; it keeps
                # resolving through its own AdGuard
                "--accept-dns=false"
            ];
            extraSetFlags = [ "--accept-dns=false" ];
        };
    };
}
