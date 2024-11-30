{ ... }: {
    networking.firewall = {
        enable = true;
        allowedTCPPortRanges = [
            { from = 4000; to = 9000; }
        ];
        allowedUDPPortRanges = [
            { from = 4000; to = 9000; }
        ];
    };
}
