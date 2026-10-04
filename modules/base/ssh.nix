# SSH client config. Every deploy-rs node (modules/deploy.nix) doubles as a
# host alias, so the address and user of a remote host are declared once.
#
# The alias block also matches the node's address, because deploy-rs and the
# nix commands it runs connect by address rather than by node name; without
# that the settings below would apply to `ssh hemlock` but not to a deploy.
#
# Connections to a node are multiplexed over one master connection. A deploy
# opens several sessions in a row (nix copy, nix build, activate, wait,
# confirm) and each would otherwise authenticate on its own, which with the
# FIDO2 key (modules/features/nitrokey.nix) means a touch per session.
# ControlPersist keeps the master alive between sessions; 10 minutes of idle
# time comfortably covers the gaps inside a deploy while still letting an
# unused master go away. The control socket path is per node (the login user
# is fixed per node, so it needs no user component) and nitrokey.nix depends
# on this exact path to tell whether a new connection will ask for a touch.
{ config, lib, ... }: let
    deploy = config.flake.deploy;
    hostAlias = name: node: let
        user = node.sshUser or deploy.sshUser or null;
    in lib.concatStringsSep "\n" ([
        "Host ${name} ${node.hostname}"
        "    HostName ${node.hostname}"
        "    ControlMaster auto"
        "    ControlPath ~/.ssh/control-${name}"
        "    ControlPersist 10m"
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
        # Skipped if a feature ever turns the agent off, so a replacement can
        # claim the variable.
        environment.etc."environment.d/10-ssh-agent.conf" = lib.mkIf config.programs.ssh.startAgent {
            text = ''
                SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
            '';
        };
    };
}
