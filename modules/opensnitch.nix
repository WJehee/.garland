{ ... }: {
    services.opensnitch = {
        enable = false;
        settings = {
            DefaultAction = "deny";
            DefaultDuration = "until restart";
            Firewall = "nftables";
            ProcMonitorMethod = "proc";
        };
    };
}
