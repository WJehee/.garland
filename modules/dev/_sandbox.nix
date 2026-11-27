# Builds a wrapper that runs an agent CLI in a rootless podman container
# instead of on the host. Used by agents.nix. Inside,
# the container sees
#
# - the project directory it was started from, at the same path, read-write
# - the nix store (read-only) and the nix daemon socket, so nix builds and
#   devenv shells work
# - the system and per-user profiles, so everything on PATH here is on PATH
#   there
# - a persistent sandbox HOME (by default a directory under XDG_DATA_HOME,
#   one per agent, mounted at the real home path) that holds the agent's own
#   state plus the jj and git configs; the real home directory is never
#   mounted
#
# The wrapper refuses to start from the home directory or any of its parents,
# since mounting those would hand the whole home directory over anyway.
#
# A project can opt in to extra podman flags by setting <NAME>_SANDBOX_ARGS
# (CLAUDE_SANDBOX_ARGS, GOOSE_SANDBOX_ARGS, ...) in its environment
# (devenv.nix: `env.CLAUDE_SANDBOX_ARGS = "...";`, picked up through direnv).
# The value is split on whitespace and appended to the `podman run` call, for
# example to hand a USB device to the session:
#   --volume /dev/bus/usb:/dev/bus/usb:dev
# Projects without the variable keep the locked-down defaults.
#
# Optionally the container gets image clipboard access: it has
# no Wayland access, but Claude Code pastes screenshots (Ctrl+V) by running
# `wl-paste -l` and `wl-paste --type image/png` itself. Mounting the Wayland
# socket would also expose clipboard text, screen capture and input
# injection, so instead the wrapper runs a clipboard broker on the host that
# answers exactly those two requests over a unix socket, and the container's
# PATH carries a `wl-paste` shim that forwards them. Any other clipboard type
# is refused on both ends.
{ config, lib, pkgs, osConfig }: let
    user = config.home.username;
    home = config.home.homeDirectory;
    podman = osConfig.virtualisation.podman.package;

    osUser = osConfig.users.users.${user};
    uid = toString osUser.uid;
    gid = toString osConfig.users.groups.${osUser.group}.gid;

    # Home-manager managed configs to mirror into the sandbox home. They are
    # store symlinks on the host, and the store is mounted, so the sandbox
    # just gets the same symlinks. Looked up by target since modules declare
    # them under different home.file keys
    managed = target: lib.findFirst (f: f.target == target) null (lib.attrValues config.home.file);
    mirrored = lib.filter (f: f != null) (map (t: managed ".config/${t}") [
        "jj/config.toml"
        "git/config"
        "git/ignore"
    ]);

    # Everything the container needs besides the (mounted) store: a shell at
    # /bin/sh, users, certificates, timezone and the host's nix config
    rootfs = pkgs.runCommand "agent-sandbox-rootfs" {} ''
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
        NAME="Agent sandbox"
        ID=agent-sandbox
        PRETTY_NAME="Agent sandbox (podman container on a NixOS host)"
        OS
    '';

    # One image for every agent: nothing in it is agent specific
    image = pkgs.dockerTools.streamLayeredImage {
        name = "localhost/agent-sandbox";
        tag = "latest";
        # Copied rather than passed as `contents`: podman reads /etc/passwd
        # itself before any mount exists, so those must be real files in the
        # layer, not symlinks into the (not included) store
        extraCommands = "cp -a ${rootfs}/. .";
        # The host store is bind mounted, no need to copy the closure
        includeStorePaths = false;
        config.Cmd = [ "/bin/sh" ];
    };
    # Shared by all agents because the image is: a marker per agent would
    # make every agent reload the image after another one loaded it
    imageMarker = "${config.xdg.dataHome}/agent-sandbox-image";

    # Host side of the clipboard broker: socat spawns one of these per
    # connection with the socket on stdin and stdout. The request is a single
    # line, either `types` or an image mime type, and the response is the raw
    # wl-paste output. The accepted types are the ones Claude Code probes
    # for, so text can never be read through here
    clipboardBroker = pkgs.writeShellApplication {
        name = "agent-clipboard-broker";
        runtimeInputs = with pkgs; [ wl-clipboard gnugrep ];
        text = ''
            IFS= read -r request || exit 1
            case "$request" in
                types)
                    wl-paste --list-types | grep -E "^image/" || true ;;
                image/png|image/jpeg|image/jpg|image/gif|image/webp|image/bmp)
                    wl-paste --type "$request" ;;
                *)
                    echo "agent-clipboard-broker: refused request: $request" >&2
                    exit 1 ;;
            esac
        '';
    };

    # Container side: shadows the real wl-paste on the sandbox PATH and
    # speaks the broker protocol. After sending the request socat half closes
    # the connection and keeps relaying the reply for at most the -t timeout;
    # the default of half a second cuts off a large screenshot
    clipboardSocket = "/run/agent-sandbox/clipboard.sock";
    wlPasteShim = pkgs.writeShellApplication {
        name = "wl-paste";
        runtimeInputs = [ pkgs.socat ];
        text = ''
            request=""
            while [ $# -gt 0 ]; do
                case "$1" in
                    -l|--list-types) request=types ;;
                    -t|--type) request="$2"; shift ;;
                    --type=*) request="''${1#--type=}" ;;
                    -n|--no-newline) ;;
                    *) echo "wl-paste: option $1 is not supported in the sandbox" >&2; exit 1 ;;
                esac
                shift
            done
            case "$request" in
                types|image/*) ;;
                *) echo "wl-paste: only image clipboard contents are available in the sandbox" >&2; exit 1 ;;
            esac
            [ -S ${clipboardSocket} ] || { echo "wl-paste: clipboard broker socket is missing" >&2; exit 1; }
            printf '%s\n' "$request" | socat -t 30 - UNIX-CONNECT:${clipboardSocket}
        '';
    };
in {
    # The command name, also the container hostname prefix and the
    # <NAME>_SANDBOX_ARGS prefix
    name,
    # Absolute path of the real executable
    program,
    sandboxDir ? "${config.xdg.dataHome}/${name}-sandbox",
    # Extra `host:container[:opts]` bind mounts
    volumes ? [],
    # Variables set inside the container unless the caller already has them
    env ? {},
    # Variables read from a file on the host at launch, so secrets reach the
    # container without entering the store or the login session. Skipped
    # when the file is unreadable (before the first activation decrypts it).
    secretEnv ? {},
    clipboard ? false,
    # Bash run on the host right before `podman run`; it may append flags to
    # the `extra` array
    preRun ? "",
    passthru ? {},
}: let
    homeMountPoints = lib.concatMap (v: let
        target = lib.elemAt (lib.splitString ":" v) 1;
    in lib.optional (lib.hasPrefix "${home}/" target) (lib.removePrefix "${home}/" target)) volumes;
in pkgs.writeShellApplication {
    inherit name passthru;
    # No runtimeInputs: that would prepend to PATH before the host PATH is
    # captured below and leak podman into the container
    runtimeInputs = [];
    text = ''
        # Inside the container the per-user profile is mounted too, so this
        # wrapper is what `${name}` resolves to: run the real thing
        if [ -e /run/.containerenv ]; then
            exec ${program} "$@"
        fi

        host_path=$PATH
        export PATH=${lib.makeBinPath [ podman pkgs.coreutils ]}:$PATH

        home=${lib.escapeShellArg home}
        pwd=$(pwd -P)
        if [ "$pwd" = / ] || [ "$pwd" = "$home" ] || [[ "$home/" == "$pwd"/* ]]; then
            echo "${name}: refusing to start in $pwd: that would expose the home directory, start from a project directory" >&2
            exit 1
        fi

        dir=${lib.escapeShellArg sandboxDir}
        sandbox="$dir/home"
        # Mount points under the home have to exist in the sandbox home,
        # otherwise podman creates them owned by root
        mkdir -p "$sandbox" ${lib.concatMapStringsSep " " (d: "\"$sandbox/${d}\"")
            (map (f: dirOf f.target) mirrored ++ homeMountPoints)}
        ${lib.concatMapStrings (f: ''
            ln -sfn ${f.source} "$sandbox/${f.target}"
        '') mirrored}

        # The marker records which image build was loaded last, so a rebuilt
        # image replaces the loaded one on the next start
        image=localhost/agent-sandbox:latest
        marker=${lib.escapeShellArg imageMarker}
        if [ "$(cat "$marker" 2>/dev/null)" != ${image} ] || ! podman image exists "$image"; then
            echo "${name}: loading sandbox image" >&2
            old=$(podman image inspect --format '{{.Id}}' "$image" 2>/dev/null || true)
            ${image} | podman load --quiet >&2
            echo ${image} > "$marker"
            # Loading untagged the previous image; drop it unless a running
            # session still uses it. The id check matters when the marker was
            # lost but the loaded image is the current one: removing it then
            # would remove the image this session is about to run
            new=$(podman image inspect --format '{{.Id}}' "$image")
            if [ -n "$old" ] && [ "$old" != "$new" ]; then
                podman rmi "$old" >/dev/null 2>&1 || true
            fi
        fi

        ${lib.concatStrings (lib.mapAttrsToList (var: value: ''
            if [ -z "''${${var}+x}" ]; then
                export ${var}=${lib.escapeShellArg value}
            fi
        '') env)}
        ${lib.concatStrings (lib.mapAttrsToList (var: file: ''
            if [ -r ${lib.escapeShellArg file} ]; then
                ${var}=$(< ${lib.escapeShellArg file})
                export ${var}
            fi
        '') secretEnv)}

        # Pass the environment through (a direnv-loaded devenv shell keeps
        # working inside) minus what belongs to this host session or gets set
        # explicitly below
        env_args=()
        while IFS= read -r -d "" kv; do
            case "''${kv%%=*}" in
                PATH|HOME|USER|LOGNAME|SHELL|PWD|OLDPWD|SHLVL|_|TMPDIR|TMP|TEMP| \
                NIX_REMOTE|SSL_CERT_FILE|NIX_SSL_CERT_FILE|TZDIR| \
                XDG_RUNTIME_DIR|XDG_SESSION_*|XDG_SEAT*|XDG_VTNR|DBUS_*|SSH_*|GPG_TTY| \
                DISPLAY|WAYLAND_DISPLAY|XAUTHORITY|HYPRLAND_*|HYPRCURSOR_*|TMUX*|DIRENV_*|*_SANDBOX_ARGS)
                    continue ;;
            esac
            env_args+=(--env "$kv")
        done < <(env -0)

        # Only PATH entries that exist inside the container: the store, the
        # mounted profiles and the project itself
        path=""
        IFS=: read -ra dirs <<< "$host_path"
        for entry in "''${dirs[@]}"; do
            case "$entry" in
                /nix/store/*|/run/current-system/*|/etc/profiles/*|"$pwd"/*)
                    path="''${path:+$path:}$entry" ;;
            esac
        done

        # Per-project extra flags, see the header
        extra=()
        args_var=${lib.toUpper name}_SANDBOX_ARGS
        if [ -n "''${!args_var:-}" ]; then
            read -ra extra <<< "''${!args_var}"
        fi

        ${lib.optionalString clipboard ''
            path=${wlPasteShim}/bin:$path
            # One broker per session so that concurrent sessions do not share
            # a socket; socat forks a broker per connection. The socket
            # directory is mounted into the container at a fixed path, so the
            # shim needs no configuration. podman is not exec'd below so that
            # the EXIT trap can tear this down when the session ends
            clipdir=$(mktemp -d "$dir/clipboard.XXXXXX")
            trap 'kill "$broker" 2>/dev/null; rm -rf "$clipdir"' EXIT
            ${pkgs.socat}/bin/socat -t 30 \
                UNIX-LISTEN:"$clipdir/clipboard.sock",fork,unlink-early,mode=600 \
                EXEC:${clipboardBroker}/bin/agent-clipboard-broker >/dev/null 2>&1 &
            broker=$!
            extra+=(--volume "$clipdir:${dirOf clipboardSocket}")
        ''}

        ${preRun}

        tty=()
        if [ -t 0 ] && [ -t 1 ]; then
            tty=(--tty)
        fi

        podman run --rm --interactive "''${tty[@]}" --init \
            --pull never \
            --hostname ${name}-sandbox \
            --userns keep-id \
            --workdir "$pwd" \
            --volume "$pwd:$pwd" \
            --volume "$sandbox:$home" \
            ${lib.concatMapStringsSep " " (v: "--volume ${lib.escapeShellArg v} ") volumes}\
            --volume /nix/store:/nix/store:ro \
            --volume /nix/var/nix/daemon-socket/socket:/nix/var/nix/daemon-socket/socket \
            --volume "$(readlink -f /run/current-system):/run/current-system:ro" \
            --volume "$(readlink -f /etc/profiles/per-user/${user}):/etc/profiles/per-user/${user}:ro" \
            --tmpfs /tmp:mode=1777 \
            "''${extra[@]}" \
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
            "$image" ${program} "$@"
    '';
}
