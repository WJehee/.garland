{ disk ? "/PATH/TO/DISK", ... }: {
    disko.devices = {
        disk = {
            main = {
                type = "disk";
                device = builtins.toPath disk;
                content = {
                    type = "gpt";
                    partitions = {
                        ESP = {
                            size = "500M";
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
                        luks = {
                            size = "100%";
                            content = {
                                type = "luks";
                                name = "crypted";
                                passwordFile = "/tmp/secret.key";
                                settings.allowDiscards = true;
                                content = {
                                    type = "lvm_pv";
                                    vg = "pool";
                                };
                            };
                        };
                    };
                };
            };
        };
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
