# Playground: a scratch area where AI agents upload static sites so they can
# be looked at in a browser. Every top-level directory of /var/www/playground
# is one site, served at https://playground.wouterjehee.com/<site>/, and the
# root of the subdomain lists the sites that exist.
#
# Sites are separated by path rather than by a subdomain each, because a
# subdomain per site needs a wildcard certificate (a DNS challenge, so DNS API
# credentials on the server) for no gain here. The price is that an uploaded
# site must use relative URLs: a reference to /assets/app.js resolves against
# the subdomain root, not against the site's directory.
#
# Upload from an agent session:
#   rsync -rlt --delete -e "ssh -i ~/.ssh/playground" ./dist/ playground@<hemlock>:<site>/
{
    flake.modules.nixos."services/playground" = { pkgs, ... }: let
        root = "/var/www/playground";
    in {
        # The whole subdomain sits behind authelia (the snippet comes from
        # modules/server/authelia.nix, the policy from its catch-all
        # *.wouterjehee.com rule). Agents can upload arbitrary HTML and
        # JavaScript, which must not be reachable by anyone but a logged in
        # user. The route block is load bearing: it keeps forward_auth ahead
        # of file_server regardless of Caddy's default directive order.
        services.caddy.virtualHosts."playground.wouterjehee.com".extraConfig = ''
            route {
                import authelia
                root * ${root}
                encode gzip
                file_server browse
            }
        '';

        # The account can do exactly one thing: run rsync confined to the
        # playground directory. `restrict` turns off the pty, all forwarding
        # and the user rc file, and the forced command replaces whatever the
        # client asked to run, so there is no shell to reach. -munge makes the
        # server defuse uploaded symlinks; without it a link to a file outside
        # the directory would be served by Caddy, which follows symlinks.
        users.users.playground = {
            isSystemUser = true;
            group = "playground";
            # sshd runs the forced command through the login shell, so
            # nologin here would lock the account out entirely.
            shell = "${pkgs.bash}/bin/bash";
            openssh.authorizedKeys.keys = let
                restrict = key: ''command="${pkgs.rrsync}/bin/rrsync -munge ${root}",restrict ${key}'';
            in [
                # Software key without a passphrase, generated inside the
                # Claude Code sandbox (modules/dev/claude-sandbox.nix) where
                # the private half lives at ~/.ssh/playground. The Nitrokey
                # keys are deliberately absent: they need a touch, which an
                # agent cannot give. Each machine whose agents should upload
                # needs its own key added here.
                (restrict "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINYX0IFsedc2LkQPSOUXm2id/2Hpn6d//pMccS9N9wkg agents@claude-sandbox")
            ];
        };
        users.groups.playground = {};
        environment.systemPackages = [ pkgs.rsync ];
        systemd.tmpfiles.rules = [
            "d ${root} 0755 playground playground -"
        ];
    };
}
