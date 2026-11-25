# Tangled knot (https://tangled.org), the git server that hosts repositories
# for the Tangled atproto forge, behind caddy at knot.wouterjehee.com. Uses
# the Rust knot (`knot-rs`) from the upstream flake; the Go knot is being
# phased out upstream. Docs: docs/src/content/docs/self-hosting/knot.md in
# the tangled core repository.
#
# The hostname is the knot's did:web identity, so it must never change.
# After the first deploy, register the knot at tangled.org under
# Settings -> Knots. Pushing and cloning go over the knot's own ssh server on
# port 2222 (the module opens it in the firewall), not hemlock's port 22.
#
# Secrets, add with `just secrets <host>`:
#   knot-master-key: base64 key that unseals the knot's signing key, generate
#                    with `openssl rand -base64 32`. Keep a copy outside this
#                    repository as well: losing it makes the sealed key in
#                    /var/lib/knot unreadable and the knot loses control of
#                    its repositories.
{ inputs, ... }: {
    flake.modules.nixos."services/knot" = { config, ... }: {
        imports = [ inputs.tangled.nixosModules.knot-rs ];

        sops.secrets."knot-master-key" = {};

        # The module reads the master key from the environment variable named
        # by settings.secrets.master_key_env (KNOT_MASTER_KEY by default).
        # systemd reads EnvironmentFile as root, so the default root
        # ownership is enough.
        sops.templates."knot.env".content = ''
            KNOT_MASTER_KEY=${config.sops.placeholder."knot-master-key"}
        '';

        # No request body limit and no CORS headers, as upstream asks: large
        # pushes and LFS uploads go through here, and the knot sets its own
        # CORS headers.
        services.caddy.virtualHosts."knot.wouterjehee.com".extraConfig = ''
            reverse_proxy 127.0.0.1:5555
        '';

        services.tangled.knot-rs = {
            enable = true;
            environmentFile = config.sops.templates."knot.env".path;
            settings = {
                server = {
                    hostname = "knot.wouterjehee.com";
                    # The first entry is advertised as the knot's owner.
                    admins = [ "did:plc:zj4x2lf7fjh7eyn7jb77i3e6" ];
                };
                atproto.plc_directory = "https://plc.directory";
                contact.email = "wouter@wouterjehee.com";
                # Caddy replaces X-Forwarded-For from clients rather than
                # appending to it (it trusts no upstream proxies by default),
                # so the header cannot be forged and the knot can rate limit
                # per client instead of treating all traffic as caddy's.
                xrpc = {
                    trusted_proxy_header = "x-forwarded-for";
                    trusted_proxies = [ "127.0.0.1" "::1" ];
                };
            };
        };
    };
}
