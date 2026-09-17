# Tailscale client, registered with the self-hosted headscale on hemlock
# (modules/server/headscale.nix). Registration is a one-off per device:
#   doas tailscale up --login-server https://headscale.wouterjehee.com
# then approve it on hemlock with `headscale nodes register`. Hosts that
# should (re)join unattended add a pre-auth key as the tailscale-authkey
# secret, see modules/features/gateway.nix for an example.
{
    flake.modules.nixos.tailscale = { config, lib, ... }: {
        services.tailscale = {
            enable = true;
            openFirewall = true;
            # Only used together with a pre-auth key
            extraUpFlags = [
                "--login-server=https://headscale.wouterjehee.com"
                "--accept-routes"
            ];
            # Applied on every start: use the home LAN route advertised by
            # the gateway
            extraSetFlags = [ "--accept-routes" ];
            authKeyFile = lib.mkIf (config.sops.secrets ? tailscale-authkey)
                config.sops.secrets.tailscale-authkey.path;
        };
        # openFirewall only opens tailscale's own UDP port; traffic arriving
        # over the tailnet is still filtered without this. Who may send what
        # over the tailnet is decided by the headscale policy.
        networking.firewall.trustedInterfaces = [ "tailscale0" ];
    };
}
