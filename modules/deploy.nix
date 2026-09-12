# deploy-rs nodes for remote deployment: `just deploy <host>`.
# Builds locally, copies the closure and activates it remotely, with
# automatic rollback if activation fails or the host becomes unreachable.
#
# This is the single place a remote host's address and login user live:
# modules/base/ssh.nix turns every node into an SSH host alias, so
# `ssh hemlock` and `just deploy hemlock` always agree.
{ config, inputs, lib, ... }: {
    flake.deploy.nodes.hemlock = {
        hostname = "88.198.175.151";
        sshUser = "admin";
        # Servers use doas instead of sudo; the admin rule is noPass, so no
        # interactiveSudo (that would prompt for a password every deploy)
        sudo = "doas -u";
        profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
                config.flake.nixosConfigurations.hemlock;
        };
    };

    # Schema and activation checks for all deploy nodes; only on
    # x86_64-linux since every node is x86_64
    perSystem = { system, ... }: {
        checks = lib.optionalAttrs (system == "x86_64-linux")
            (inputs.deploy-rs.lib.${system}.deployChecks config.flake.deploy);
    };
}
