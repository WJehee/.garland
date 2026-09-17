# Headscale: self-hosted Tailscale control server, the coordination point for
# remote access to the home network. Nodes register here, get their tailnet
# address and the ACL policy below, and then talk to each other directly
# (or through Tailscale's public DERP relays when NAT traversal fails), so
# the home network needs no open port and no dynamic DNS.
#
# Runs on hemlock behind caddy, which terminates TLS. Wormwood advertises
# the home LAN as a subnet route (see modules/features/gateway.nix), other
# hosts import the tailscale feature.
#
# Users and pre-auth keys are runtime state created with the headscale CLI,
# see docs/remote-access.adoc.
{
    flake.modules.nixos."services/headscale" = { pkgs, ... }:
    let
        domain = "headscale.wouterjehee.com";
        port = 8080;
        lan = "192.168.178.0/24";
        adguard = "192.168.178.44";
        homeAssistant = "192.168.178.43";
        # Access control. Group membership follows the headscale user a node
        # is registered under, so the user chosen at registration decides
        # what a device may reach. Tagged nodes (the gateway) belong to no
        # user.
        policy = (pkgs.formats.json { }).generate "headscale-policy.json" {
            groups = {
                # Full access: the LAN, every tailnet node and the internet
                "group:admin" = [ "wouter@" ];
                # DNS via AdGuard plus Home Assistant, nothing else
                "group:restricted" = [ "guest@" ];
            };
            tagOwners = {
                "tag:gateway" = [ "group:admin" ];
            };
            hosts = {
                lan = lan;
                adguard = "${adguard}/32";
                home-assistant = "${homeAssistant}/32";
            };
            acls = [
                {
                    action = "accept";
                    src = [ "group:admin" ];
                    dst = [ "*:*" ];
                }
                {
                    action = "accept";
                    src = [ "group:restricted" ];
                    dst = [
                        "home-assistant:8123"
                        "adguard:53"
                    ];
                }
            ];
            # The gateway's LAN route is approved as soon as it advertises
            # it, no `headscale nodes approve-routes` needed after a reflash
            autoApprovers.routes.${lan} = [ "tag:gateway" ];
        };
    in {
        services.headscale = {
            enable = true;
            address = "127.0.0.1";
            inherit port;
            settings = {
                server_url = "https://${domain}";
                policy.path = policy;
                dns = {
                    magic_dns = true;
                    # Must differ from the server_url domain; nodes become
                    # <hostname>.tailnet.wouterjehee.com
                    base_domain = "tailnet.wouterjehee.com";
                    # AdGuard on wormwood, reached through the subnet route,
                    # so DNS filtering applies to every node wherever it is.
                    # Hosts that should keep their own resolver (wormwood
                    # itself, hemlock) run tailscale with --accept-dns=false
                    nameservers.global = [ adguard ];
                    override_local_dns = true;
                };
            };
        };
        services.caddy.virtualHosts.${domain}.extraConfig = ''
            reverse_proxy http://localhost:${toString port}
        '';
    };
}
