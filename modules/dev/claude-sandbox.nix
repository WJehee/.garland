# Claude Code never runs on the host: `claude` is a wrapper that starts the
# real binary in a rootless podman container. Inside, the container sees
#
# - the project directory it was started from, at the same path, read-write
# - the nix store (read-only) and the nix daemon socket, so nix builds and
#   devenv shells work
# - the system and per-user profiles, so everything on PATH here is on PATH
#   there
# - a persistent sandbox HOME (a directory under XDG_DATA_HOME, mounted at the
#   real home path) that only holds the Claude config dir plus the jj and git
#   configs; the real home directory is never mounted
#
# The wrapper refuses to start from the home directory or any of its parents,
# since mounting those would hand the whole home directory over anyway.
{
    flake.modules.homeManager.dev = { config, lib, pkgs, osConfig, ... }: let
        claude = pkgs.claude-code;
        user = config.home.username;
        home = config.home.homeDirectory;
        configDir = config.programs.claude-code.configDir;
        sandboxDir = "${config.xdg.dataHome}/claude-sandbox";

        osUser = osConfig.users.users.${user};
        uid = toString osUser.uid;
        gid = toString osConfig.users.groups.${osUser.group}.gid;

        # Home-manager managed configs to mirror into the sandbox home. They
        # are store symlinks on the host, and the store is mounted, so the
        # sandbox just gets the same symlinks. Looked up by target since
        # modules declare them under different home.file keys
        managed = target: lib.findFirst (f: f.target == target) null (lib.attrValues config.home.file);
        mirrored = lib.filter (f: f != null) (map (t: managed ".config/${t}") [
            "jj/config.toml"
            "git/config"
            "git/ignore"
        ]);

        # Everything the container needs besides the (mounted) store: a shell
        # at /bin/sh, users, certificates, timezone and the host's nix config
        rootfs = pkgs.runCommand "claude-sandbox-rootfs" {} ''
            mkdir -p $out/{bin,usr/bin,etc/nix,etc/ssl/certs,tmp,home}
            ln -s ${pkgs.bash}/bin/bash $out/bin/sh
            ln -s ${pkgs.bash}/bin/bash $out/bin/bash
            ln -s ${pkgs.coreutils}/bin/env $out/usr/bin/env
            ln -s ${osConfig.environment.etc."nix/nix.conf".source} $out/etc/nix/nix.conf
            ln -s ${osConfig.environment.etc."nix/registry.json".source} $out/etc/nix/registry.json
            ln -s ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt $out/etc/ssl/certs/ca-bundle.crt
            ln -s ca-bundle.crt $out/etc/ssl/certs/ca-certificates.crt
            ln -s ${pkgs.tzdata}/share/zoneinfo $out/etc/zoneinfo
            ln -s ${pkgs.tzdata}/share/zoneinfo/${osConfig.time.timeZone} $out/etc/localtime
            cat > $out/etc/passwd <<PASSWD
            root:x:0:0:root:/root:/bin/sh
            ${user}:x:${uid}:${gid}:${user}:${home}:/bin/bash
            nobody:x:65534:65534:nobody:/:/bin/sh
            PASSWD
            cat > $out/etc/group <<GROUP
            root:x:0:
            ${osUser.group}:x:${gid}:
            nogroup:x:65534:
            GROUP
            cat > $out/etc/nsswitch.conf <<NSS
            passwd: files
            group: files
            hosts: files dns
            NSS
            cat > $out/etc/os-release <<OS
            NAME="Claude sandbox"
            ID=claude-sandbox
            PRETTY_NAME="Claude Code sandbox (podman container on a NixOS host)"
            OS
        '';

        image = pkgs.dockerTools.streamLayeredImage {
            name = "localhost/claude-sandbox";
            tag = "latest";
            # Copied rather than passed as `contents`: podman reads /etc/passwd
            # itself before any mount exists, so those must be real files in
            # the layer, not symlinks into the (not included) store
            extraCommands = "cp -a ${rootfs}/. .";
            # The host store is bind mounted, no need to copy the closure
            includeStorePaths = false;
            config.Cmd = [ "/bin/sh" ];
        };

        sandbox = pkgs.writeShellApplication {
            name = "claude";
            # No runtimeInputs: that would prepend to PATH before the host
            # PATH is captured below and leak podman into the container
            runtimeInputs = [];
            # The real version keeps home-manager's version-gated behaviour
            # (personal plugins instead of the legacy --plugin-dir wrapper)
            passthru = { inherit (claude) version; };
            text = ''
                # Inside the container the per-user profile is mounted too, so
                # this wrapper is what `claude` resolves to: run the real thing
                if [ -e /run/.containerenv ]; then
                    exec ${claude}/bin/claude "$@"
                fi

                host_path=$PATH
                export PATH=${lib.makeBinPath [ osConfig.virtualisation.podman.package pkgs.coreutils ]}:$PATH

                home=${lib.escapeShellArg home}
                pwd=$(pwd -P)
                if [ "$pwd" = / ] || [ "$pwd" = "$home" ] || [[ "$home/" == "$pwd"/* ]]; then
                    echo "claude: refusing to start in $pwd: that would expose the home directory, start from a project directory" >&2
                    exit 1
                fi

                dir=${lib.escapeShellArg sandboxDir}
                sandbox="$dir/home"
                mkdir -p "$sandbox/.config/claude" ${lib.concatMapStringsSep " " (f: "\"$sandbox/${dirOf f.target}\"") mirrored}
                ${lib.concatMapStrings (f: ''
                    ln -sfn ${f.source} "$sandbox/${f.target}"
                '') mirrored}

                # The marker records which image build was loaded last, so a
                # rebuilt image replaces the loaded one on the next start
                image=localhost/claude-sandbox:latest
                if [ "$(cat "$dir/image" 2>/dev/null)" != ${image} ] || ! podman image exists "$image"; then
                    echo "claude: loading sandbox image" >&2
                    old=$(podman image inspect --format '{{.Id}}' "$image" 2>/dev/null || true)
                    ${image} | podman load --quiet >&2
                    echo ${image} > "$dir/image"
                    # Loading untagged the previous image; drop it unless a
                    # running session still uses it
                    if [ -n "$old" ]; then
                        podman rmi "$old" >/dev/null 2>&1 || true
                    fi
                fi

                # Pass the environment through (a direnv-loaded devenv shell
                # keeps working inside) minus what belongs to this host
                # session or gets set explicitly below
                env_args=()
                while IFS= read -r -d "" kv; do
                    case "''${kv%%=*}" in
                        PATH|HOME|USER|LOGNAME|SHELL|PWD|OLDPWD|SHLVL|_|TMPDIR|TMP|TEMP| \
                        NIX_REMOTE|SSL_CERT_FILE|NIX_SSL_CERT_FILE|TZDIR| \
                        XDG_RUNTIME_DIR|XDG_SESSION_*|XDG_SEAT*|XDG_VTNR|DBUS_*|SSH_*|GPG_TTY| \
                        DISPLAY|WAYLAND_DISPLAY|XAUTHORITY|HYPRLAND_*|HYPRCURSOR_*|TMUX*|DIRENV_*)
                            continue ;;
                    esac
                    env_args+=(--env "$kv")
                done < <(env -0)

                # Only PATH entries that exist inside the container: the
                # store, the mounted profiles and the project itself
                path=""
                IFS=: read -ra dirs <<< "$host_path"
                for entry in "''${dirs[@]}"; do
                    case "$entry" in
                        /nix/store/*|/run/current-system/*|/etc/profiles/*|"$pwd"/*)
                            path="''${path:+$path:}$entry" ;;
                    esac
                done

                tty=()
                if [ -t 0 ] && [ -t 1 ]; then
                    tty=(--tty)
                fi

                exec podman run --rm --interactive "''${tty[@]}" --init \
                    --pull never \
                    --hostname claude-sandbox \
                    --userns keep-id \
                    --workdir "$pwd" \
                    --volume "$pwd:$pwd" \
                    --volume "$sandbox:$home" \
                    --volume ${lib.escapeShellArg "${configDir}:${configDir}"} \
                    --volume /nix/store:/nix/store:ro \
                    --volume /nix/var/nix/daemon-socket/socket:/nix/var/nix/daemon-socket/socket \
                    --volume "$(readlink -f /run/current-system):/run/current-system:ro" \
                    --volume "$(readlink -f /etc/profiles/per-user/${user}):/etc/profiles/per-user/${user}:ro" \
                    --tmpfs /tmp:mode=1777 \
                    "''${env_args[@]}" \
                    --env HOME="$home" \
                    --env USER=${user} \
                    --env LOGNAME=${user} \
                    --env SHELL=/bin/bash \
                    --env PATH="$path" \
                    --env NIX_REMOTE=daemon \
                    --env SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt \
                    --env NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt \
                    --env TZDIR=/etc/zoneinfo \
                    "$image" ${claude}/bin/claude "$@"
            '';
        };
    in {
        assertions = [{
            assertion = osConfig.virtualisation.podman.enable;
            message = "The Claude Code sandbox needs podman on the host: import nixos.podman";
        }];

        programs.claude-code.package = sandbox;
    };
}
