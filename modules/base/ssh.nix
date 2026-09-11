{
    flake.modules.nixos.base = { config, lib, ... }: {
        programs.ssh = {
            startAgent = true;
            extraConfig = "
            Host hemlock
                Hostname 88.198.175.151
                User admin

            Host ivy
                Hostname 192.168.178.43
                User admin

            Host wormwood
                Hostname 192.168.178.44
                User admin
        ";
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
