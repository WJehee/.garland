# deploy-rs nodes for remote deployment: `just deploy <host>`.
# Builds locally, copies the closure and activates it remotely, with
# automatic rollback if activation fails or the host becomes unreachable.
#
# This is the single place a remote host's address and login user live:
# modules/base/ssh.nix turns every node into an SSH host alias, so
# `ssh hemlock` and `just deploy hemlock` always agree.
{ config, inputs, lib, ... }: let
    activate = inputs.deploy-rs.lib.x86_64-linux.activate.nixos;
    # Remote hosts, keyed by node name (must match the nixosConfiguration).
    # remoteBuild: build on the host itself instead of locally and copying
    # the closure over. Off for small VPSes, on for machines with more
    # compute than the deploying laptop.
    hosts = {
        hemlock = { hostname = "88.198.175.151"; remoteBuild = false; };
    };
in {
    flake.deploy = {
        sshUser = "admin";
        user = "root";
        sudo = "doas -u";

        nodes = lib.mapAttrs (name: host: host // {
            profiles.system.path = activate config.flake.nixosConfigurations.${name};
        }) hosts;
    };

    # Schema and activation checks for all deploy nodes; only on
    # x86_64-linux since every node is x86_64
    perSystem = { system, ... }: {
        checks = lib.optionalAttrs (system == "x86_64-linux")
            (inputs.deploy-rs.lib.${system}.deployChecks config.flake.deploy);
    };
}
