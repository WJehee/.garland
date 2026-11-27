{
    # Linux audit daemon with laurel (https://github.com/threathunters-io/laurel)
    # as an audisp plugin. auditd keeps writing the raw multi-line records to
    # /var/log/audit/audit.log; laurel turns each event into a single enriched
    # JSON line (process tree, script names, argv as an array) in
    # /var/log/laurel/audit.log, which is what a SIEM or a human with jq wants.
    flake.modules.nixos.auditd = { lib, pkgs, ... }: let
        toml = pkgs.formats.toml { };
        laurelConfig = toml.generate "laurel.toml" {
            directory = "/var/log/laurel";
            # laurel starts as root (auditd spawns its plugins as root) and drops
            # to this user after opening the netlink input and log directory.
            user = "laurel";
            auditlog = {
                file = "audit.log";
                size = 50000000;
                generations = 10;
            };
            transform.execve-argv = [ "array" ];
            translate = {
                # Resolving uid/gid to names in laurel itself; auditd's own
                # "enriched" format is off by default on NixOS.
                user-db = true;
                universal = true;
            };
            enrich = {
                pid = true;
                script = true;
                execve-env = [ "LD_PRELOAD" "LD_LIBRARY_PATH" ];
            };
        };
    in {
        users.users.laurel = {
            isSystemUser = true;
            group = "laurel";
        };
        users.groups.laurel = { };

        security.audit = {
            enable = true;
            rules = [
                # Every program execution, the core event laurel enriches.
                "-a always,exit -F arch=b64 -S execve,execveat -k exec"
            ]
            # On x86_64 the 32-bit syscall ABI is a separate audit arch that the
            # b64 rule does not match, and running a 32-bit binary is an easy
            # way around it.
            ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
                "-a always,exit -F arch=b32 -S execve -k exec"
            ]
            ++ [
                # Account databases are real files that NixOS activation and
                # passwd/usermod edit in place. Most other /etc files are
                # symlinks into the read-only store, so watching them would only
                # ever log activation.
                "-w /etc/passwd -p wa -k identity"
                "-w /etc/group -p wa -k identity"
                "-w /etc/shadow -p wa -k identity"
                # Kernel module loading, a common rootkit step.
                "-a always,exit -F arch=b64 -S init_module,finit_module,delete_module -k modules"
            ];
        };

        security.auditd = {
            enable = true;
            plugins.laurel = {
                active = true;
                path = lib.getExe' pkgs.laurel "laurel";
                args = [ "--config" "${laurelConfig}" ];
                format = "string";
            };
        };
    };
}
