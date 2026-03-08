{ lib, pkgs, ... }: {
    networking.nftables.enable = true; 
    services.opensnitch = {
        enable = true;
        settings = {
            DefaultAction = "deny";
            DefaultDuration = "until restart";
            Firewall = "nftables";
            ProcMonitorMethod = "proc";
        };
        rules = {
            systemd-timesyncd = {
                name = "systemd-timesyncd";
                enabled = true;
                action = "allow";
                duration = "always";
                operator = {
                    type ="simple";
                    sensitive = false;
                    operand = "process.path";
                    data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
                };
            };
            systemd-resolved = {
                name = "systemd-resolved";
                enabled = true;
                action = "allow";
                duration = "always";
                operator = {
                    type ="simple";
                    sensitive = false;
                    operand = "process.path";
                    data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
                };
            };
            spotify = {
                name = "spotify";
                enabled = true;
                action = "allow";
                duration = "always";
                operator = {
                    type = "simple";
                    sensititve = false;
                    operand = "process.path";
                    data = "${lib.getBin pkgs.spotify}/share/spotify/.spotify-wrapped";
                };
            };
            syncthing = {
                name = "syncthing";
                enabled = true;
                action = "allow";
                duration = "always";
                operator = {
                    type = "simple";
                    sensitive = false;
                    operand = "process.path";
                    data = "${lib.getBin pkgs.syncthing}/bin/syncthing";
                };
            };
            networkmanager = {
                name = "networkmanager";
                enable = true;
                action = "allow";
                duration = "always";
                operator = {
                    type = "simple";
                    sensitive = false;
                    operand = "process.path";
                    data = "${lib.getBin pkgs.networkmanager}/bin/NetworkManager";
                };
            };
        };
    };
}
