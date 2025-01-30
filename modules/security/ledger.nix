{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        ledger-live-desktop
    ];
    users = {
        groups.plugdev = {};
        users.wouter.extraGroups = [
            "plugdev"
        ];
    };
    hardware.ledger.enable = true;
}
