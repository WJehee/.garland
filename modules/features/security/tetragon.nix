{
    # Tetragon: eBPF based process, file and network observability with optional
    # in-kernel enforcement (https://tetragon.io).
    #
    # Why not services.tetragon: nixpkgs packages tetragon but ships no NixOS
    # module, so the unit below is modelled on upstream's linux-tarball install
    # (install/linux-tarball/usr/lib/systemd/system/tetragon.service).
    #
    # Without tracing policies tetragon still exports process_exec and
    # process_exit events for every process. Policies (TracingPolicy YAML, see
    # https://tetragon.io/docs/concepts/tracing-policy/) go in
    # environment.etc."tetragon/tetragon.tp.d/<name>.yaml", the directory
    # tetragon loads on startup.
    flake.modules.nixos.tetragon = { lib, pkgs, ... }: let
        tetragon = pkgs.tetragon;
    in {
        environment.systemPackages = [ tetragon ];

        systemd.services.tetragon = {
            description = "Tetragon eBPF-based Security Observability and Runtime Enforcement";
            wantedBy = [ "multi-user.target" ];
            after = [ "local-fs.target" ];
            serviceConfig = {
                # tetragon loads BPF programs, attaches kprobes and reads every
                # process' /proc entries, so it needs full root; sandboxing it with
                # systemd options mostly breaks the probes.
                ExecStart = lib.concatStringsSep " " [
                    (lib.getExe tetragon)
                    "--bpf-lib ${tetragon}/lib/tetragon/bpf/"
                    # The upstream default is a TCP listener on localhost:54321,
                    # which any local user can talk to. A root-only unix socket
                    # keeps the event stream and policy API to root. tetra finds
                    # it through /run/tetragon/tetragon-info.json, which tetragon
                    # writes on startup.
                    "--server-address unix:///run/tetragon/tetragon.sock"
                    "--export-filename /var/log/tetragon/tetragon.log"
                    "--export-file-compress"
                    "--health-server-address ''"
                ];
                # tetragon hardcodes /var/run/tetragon for its pid file, info file
                # and persisted policies; /var/run is a symlink to /run on NixOS.
                RuntimeDirectory = "tetragon";
                RuntimeDirectoryMode = "0700";
                LogsDirectory = "tetragon";
                LogsDirectoryMode = "0700";
                Restart = "on-failure";
                # Detaching BPF programs on a large policy set can take a while.
                TimeoutStopSec = "90s";
            };
        };
    };
}
