{ ... }: {
    services.borgbackup.jobs."borgbase" = {
        paths = [
            "/home/wouter/Sync"
        ];
        repo = "ssh://b49ad843@b49ad843.repo.borgbase.com/./repo";
        encryption = {
            mode = "repokey-blake2";
            passCommand = "cat /root/borg/passphrase";
        };
        environment.BORG_RSH = "ssh -i /root/borg/ssh_key";
        compression = "auto,lzma";
        startAt = "daily";
    };
}
