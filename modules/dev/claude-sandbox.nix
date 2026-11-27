# Claude Code runs on the host, confined by its own sandbox: Bash commands
# run under bubblewrap with writes limited to the working directory and
# network access limited to approved domains. Unlike goose and hermes
# (./agents.nix), Claude does not run in the podman container of
# ./_sandbox.nix, so it can drive herdr through HERDR_SOCKET_PATH.
#
# In the context of agent-driven herdr workspaces, facing a podman container
# whose isolation the herdr socket bypasses anyway (herdr runs commands in
# host panes, outside any sandbox), we chose Claude Code's built-in sandbox
# to keep herdr control without a socket-filtering broker, accepting that
# Claude's own file tools (Read, Edit, Write) are governed by permission
# rules only, that it can read the whole home directory, and that the herdr
# socket can still run anything in a host pane.
#
# Hosts that import the `playground-key` NixOS feature below additionally get
# the upload key for the playground on hemlock (modules/server/playground.nix)
# at ~/.ssh/playground. The key comes from sops, so every workstation shares
# one key. Add it with `just secrets <host>` as `playground-ssh-key` (the
# full private key file, as a YAML block scalar ending in a newline; ssh
# rejects a key file without the trailing newline).
{
    flake.modules.nixos.playground-key = {
        # sops-nix's default mode 0400 is what ssh insists on for a private
        # key; the owner lets the user's ssh read it through the symlink.
        sops.secrets."playground-ssh-key".owner = "wouter";
    };

    flake.modules.homeManager.dev = { config, lib, pkgs, osConfig, ... }: let
        claudeDir = config.programs.claude-code.configDir;

        # Null on hosts that do not import the playground-key feature, which
        # keeps this module usable without the secret.
        playgroundKey = osConfig.sops.secrets."playground-ssh-key".path or null;

        sandboxSettings = builtins.toJSON {
            sandbox = {
                enabled = true;
                # On Linux the sandbox cannot allow a unix socket by path
                # (allowUnixSockets is ignored there), so it is all or none.
                # herdr (HERDR_SOCKET_PATH) and the nix daemon socket, which
                # nix and devenv inside sandboxed commands need, both require
                # this.
                network.allowAllUnixSockets = true;
            };
        };
    in {
        # The sandbox shells out to these for the filesystem namespace and
        # the network proxy.
        home.packages = [ pkgs.bubblewrap pkgs.socat ];

        # Merged into settings.json at activation instead of set through
        # programs.claude-code.settings, which would make the file a
        # read-only store symlink and break runtime edits from /config and
        # /sandbox (see ./llm.nix). Keys set here win over whatever is in the
        # file; everything else in it is kept.
        home.activation.claudeSandboxSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            settings=${lib.escapeShellArg "${claudeDir}/settings.json"}
            current='{}'
            if [ -s "$settings" ]; then current=$(< "$settings"); fi
            merged=$(${lib.getExe pkgs.jq} -n --argjson cur "$current" \
                --argjson new ${lib.escapeShellArg sandboxSettings} '$cur * $new')
            run mkdir -p ${lib.escapeShellArg claudeDir}
            run ${pkgs.coreutils}/bin/install -m 0644 /dev/stdin "$settings" <<< "$merged"
        '';

        home.file = lib.optionalAttrs (playgroundKey != null) {
            # Out of store, since the key exists only after sops-nix decrypts
            # it at system activation.
            ".ssh/playground".source = config.lib.file.mkOutOfStoreSymlink playgroundKey;
        };
    };
}
