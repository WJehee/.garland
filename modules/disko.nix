{ ... }: {
    disko.devices = {
        disk = {
            main = {
                type = "disk";
                device = "...";
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
                                extraOpenArgs = [ ];
                                settings = {
                                    keyFile = "/tmp/secret.key";
                                    allowDiscards = true;
                                };
                                additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
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
                        size = "100%";
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
