{ ... }: {
    networking.firewall = {
        enable = true;
        allowedTCPPortRanges = [
            { from = 1000; to = 9999; }
        ];
        allowedUDPPortRanges = [
            { from = 1000; to = 9999; }
        ];
    };
}
