# deploy-rs nodes for remote deployment. `just deploy <host>` builds on the
# host (only the derivations are copied; the host reuses its own store and
# pulls the rest from cache.nixos.org), `just deploy-local <host>` builds
# here and copies the closure. Both activate remotely with automatic
# rollback if activation fails or the host becomes unreachable.
#
# This is the single place a remote host's address and login user live:
# modules/base/ssh.nix turns every node into an SSH host alias, so
# `ssh hemlock` and `just deploy hemlock` always agree.
{ config, inputs, lib, ... }: let
    activate = inputs.deploy-rs.lib.x86_64-linux.activate.nixos;
    # Remote hosts, keyed by node name (must match the nixosConfiguration).
    # remoteBuild must stay false: the deploy-rs `--remote-build` flag can
    # only turn remote building on, never off, so the justfile adds it for
    # the default `just deploy` and omits it for `just deploy-local`. A true
    # here would make local builds (for compiling custom packages on the
    # faster machine) impossible.
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
