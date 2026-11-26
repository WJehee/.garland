# Claude Code never runs on the host: `claude` is a wrapper that starts the
# real binary in a rootless podman container, built by ./_sandbox.nix (see
# there for what the container sees). On top of the common sandbox, Claude
# gets its config dir mounted at the same path and image clipboard access
# for pasting screenshots.
#
# Hosts that import the `playground-key` NixOS feature below additionally get
# the upload key for the playground on hemlock (modules/server/playground.nix)
# mounted read-only at ~/.ssh/playground. The key comes from sops, so every
# workstation shares one key and it survives wiping the sandbox home. Add it
# with `just secrets <host>` as `playground-ssh-key` (the full private key
# file, as a YAML block scalar ending in a newline; ssh rejects a key file
# without the trailing newline).
{
    flake.modules.nixos.playground-key = {
        # Owned by the user because the rootless container maps only that
        # uid; sops-nix's default mode 0400 is also what ssh insists on for
        # a private key.
        sops.secrets."playground-ssh-key".owner = "wouter";
    };

    flake.modules.homeManager.dev = { config, lib, pkgs, osConfig, ... }: let
        claude = pkgs.claude-code;
        home = config.home.homeDirectory;
        configDir = config.programs.claude-code.configDir;
        mkSandbox = import ./_sandbox.nix { inherit config lib pkgs osConfig; };

        # Null on hosts that do not import the playground-key feature, which
        # keeps this module usable without the secret.
        playgroundKey = osConfig.sops.secrets."playground-ssh-key".path or null;
    in {
        assertions = [{
            assertion = osConfig.virtualisation.podman.enable;
            message = "The agent sandboxes (claude, goose, hermes) need podman on the host: import nixos.podman";
        }];

        programs.claude-code.package = mkSandbox {
            name = "claude";
            program = "${claude}/bin/claude";
            volumes = [ "${configDir}:${configDir}" ];
            clipboard = true;
            # The real version keeps home-manager's version-gated behaviour
            # (personal plugins instead of the legacy --plugin-dir wrapper)
            passthru = { inherit (claude) version; };
            preRun = lib.optionalString (playgroundKey != null) ''
                # Resolved first because the path is a symlink into the
                # current sops generation and podman must bind the file
                # itself. The test covers the window between adding the
                # feature and the first activation that decrypts the key.
                # The mount point directory has to exist in the sandbox
                # home, otherwise podman creates it owned by root.
                if [ -r ${playgroundKey} ]; then
                    mkdir -p "$sandbox/.ssh"
                    extra+=(--volume "$(readlink -f ${playgroundKey}):${home}/.ssh/playground:ro")
                fi
            '';
        };
    };
}
