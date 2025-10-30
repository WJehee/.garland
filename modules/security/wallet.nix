{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        ledger-live-desktop
        trezor-suite
    ];
    users = {
        groups.plugdev = {};
        users.wouter.extraGroups = [
            "plugdev"
        ];
    };
    hardware.ledger.enable = true;
    services.trezord.enable = true;
}
