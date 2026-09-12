# SSH client config. Every deploy-rs node (modules/deploy.nix) doubles as a
# host alias, so the address and user of a remote host are declared once.
{ config, lib, ... }: let
    hostAlias = name: node: lib.concatStringsSep "\n" ([
        "Host ${name}"
        "    HostName ${node.hostname}"
    ] ++ lib.optional (node ? sshUser) "    User ${node.sshUser}") + "\n";
    hostAliases = lib.concatStrings
        (lib.mapAttrsToList hostAlias config.flake.deploy.nodes);
in {
    flake.modules.nixos.base = { config, lib, ... }: {
        programs.ssh = {
            startAgent = true;
            extraConfig = hostAliases;
        };
        # startAgent only exports SSH_AUTH_SOCK from shell init. The desktop
        # shell (noctalia) is a systemd user service and everything launched
        # from it inherits its environment, so without this the agent is
        # invisible to graphical apps (keepassxc could not add keys).
        # environment.d is where the user manager takes its environment from.
        # Skipped when a feature replaces the agent (nitrokey forces startAgent
        # off in favour of gpg-agent).
        environment.etc."environment.d/10-ssh-agent.conf" = lib.mkIf config.programs.ssh.startAgent {
            text = ''
                SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
            '';
        };
    };
}
