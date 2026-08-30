{
    flake.modules.nixos.backup = { config, lib, ... }: {
        # Add both to the host's secrets file with `just secrets <host>`:
        # borg-passphrase: the repo encryption passphrase
        # borg-ssh-key: private key authorized on the backup target
        sops.secrets."borg-passphrase" = {};
        sops.secrets."borg-ssh-key" = {};

        # TODO: replace with the real repo (Hetzner Storage Box, BorgBase,
        # or another machine) before importing this module anywhere
        services.borgbackup.jobs.system = {
            repo = "ssh://uXXXXXX@uXXXXXX.your-storagebox.de:23/./borg/${config.networking.hostName}";
            encryption = {
                mode = "repokey-blake2";
                passCommand = "cat ${config.sops.secrets."borg-passphrase".path}";
            };
            environment.BORG_RSH = "ssh -i ${config.sops.secrets."borg-ssh-key".path}";

            paths = [
                "/var/lib"
                "/home"
                "/var/backup"
            ];
            exclude = [
                "/home/*/.cache"
                "/home/*/.local/share/Trash"
                "/var/lib/systemd"
                # Live postgres files are inconsistent; the pg_dumpall dump in
                # /var/backup is what gets restored
                "/var/lib/postgresql"
            ];

            compression = "auto,zstd";
            startAt = "daily";
            # Run a missed backup on the next boot (laptops)
            persistentTimer = true;
            prune.keep = {
                daily = 7;
                weekly = 4;
                monthly = 6;
            };
        };

        # Dump postgres to /var/backup so borg picks up a consistent copy
        services.postgresqlBackup = {
            enable = lib.mkDefault config.services.postgresql.enable;
            backupAll = true;
        };
    };
}
