# The luks-lvm layout spread over several disks: every disk carries its own
# LUKS container, and all containers are physical volumes of the one volume
# group `pool`, so swap and root see the combined capacity. The first disk in
# `disks` additionally holds the ESP.
#
# The volume group is a linear span, not a RAID: in the context of a
# workstation whose data lives in git and backups, facing two unequal or
# unpaired drives, we chose spanning to get the full combined capacity,
# accepting that losing any one drive loses the whole volume group.
#
# Every container is formatted with the same passphrase (/tmp/secret.key on
# the install target). That is load-bearing for booting: the systemd initrd
# caches the first passphrase typed and retries it on the remaining
# containers, so one prompt unlocks all of them. Giving a container a
# different passphrase later means one prompt per container.
#
# `disks` has no default and must be set by the importing host through
# `_module.args.disks`. It is only read when partitioning at install time; the
# installed system finds everything by partition label and LVM name, so the
# device paths may change afterwards without consequences.
{ lib, disks, ... }: let
    # The first disk keeps the names of the single-disk layout ("main",
    # "crypted"); further disks are numbered from 2.
    diskName = index: if index == 0 then "main" else "extra${toString (index + 1)}";
    luksName = index: if index == 0 then "crypted" else "crypted${toString (index + 1)}";

    luksPartition = index: {
        size = "100%";
        content = {
            type = "luks";
            name = luksName index;
            passwordFile = "/tmp/secret.key";
            settings.allowDiscards = true;
            content = {
                type = "lvm_pv";
                vg = "pool";
            };
        };
    };

    espPartition = {
        size = "1G";
        type = "EF00";
        content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
                "defaults"
            ];
        };
    };
in {
    disko.devices = {
        disk = lib.listToAttrs (lib.imap0 (index: device: {
            name = diskName index;
            value = {
                type = "disk";
                inherit device;
                content = {
                    type = "gpt";
                    partitions =
                        lib.optionalAttrs (index == 0) { ESP = espPartition; }
                        // { luks = luksPartition index; };
                };
            };
        }) disks);
        lvm_vg = {
            pool = {
                type = "lvm_vg";
                lvs = {
                    swap = {
                        size = "8G";
                        content = {
                            type = "swap";
                            randomEncryption = true;
                            priority = 100;
                        };
                    };
                    rest = {
                        size = "100%FREE";
                        content = {
                            type = "filesystem";
                            format = "ext4";
                            mountpoint = "/";
                            mountOptions = [
                                "defaults"
                            ];
                        };
                    };
                };
            };
        };
    };
}
