# SSH client config. Every deploy-rs node (modules/deploy.nix) doubles as a
# host alias, so the address and user of a remote host are declared once.
{ config, lib, ... }: let
    deploy = config.flake.deploy;
    hostAlias = name: node: let
        user = node.sshUser or deploy.sshUser or null;
    in lib.concatStringsSep "\n" ([
        "Host ${name}"
        "    HostName ${node.hostname}"
    ] ++ lib.optional (user != null) "    User ${user}") + "\n";
    hostAliases = lib.concatStrings
        (lib.mapAttrsToList hostAlias deploy.nodes);
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
