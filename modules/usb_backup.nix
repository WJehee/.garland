{ pkgs, ... }: {
    systemd.services."usb-backup" = {
        script = ''
            /run/wrappers/bin/mount /dev/sdb1 /mnt/usb -o umask=0077,uid=1000,gid=100
            /run/current-system/sw/bin/rsync -rtDvz /home/wouter/Sync/ /mnt/usb/Data/Sync
            /run/wrappers/bin/umount -r /mnt/usb
        '';
    };
    services.udev.extraRules = ''
        SUBSYSTEM=="block", ACTION=="add", ATTRS{serial}=="0302821020001662", RUN+="${pkgs.systemd}/bin/systemctl start usb-backup"
    '';
}

