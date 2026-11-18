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
# the install target). That is load-bearing for booting: systemd-cryptsetup
# stores a typed passphrase in the kernel keyring and tries that cache before
# prompting, so one prompt can unlock all containers. Giving a container a
# different passphrase later means one prompt per container. See the unit
# ordering at the bottom of this file for what makes the cache actually hit.
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

    # Unlock the first container before the others. systemd-cryptsetup looks
    # in the passphrase cache only once, when its unit starts. Without an
    # ordering all units start in parallel, every one of them finds the cache
    # empty and queues its own prompt, so the passphrase has to be typed once
    # per disk. Started after the first container is open, the others find the
    # passphrase in the keyring and never prompt. After= only orders: if the
    # first unlock fails, the others still start and prompt themselves.
    #
    # The units come from systemd-cryptsetup-generator at boot, so this has to
    # be a drop-in; a full unit file here would shadow the generated one.
    boot.initrd.systemd.services = lib.listToAttrs (lib.imap1 (offset: _: {
        name = "systemd-cryptsetup@${luksName offset}";
        value = {
            overrideStrategy = "asDropin";
            after = [ "systemd-cryptsetup@${luksName 0}.service" ];
        };
    }) (lib.tail disks));
}
