{ pkgs, ... }: {
    hardware.rtl-sdr.enable = true;
    users = {
        groups.plugdev = {};
        users.wouter.extraGroups = [
            "plugdev"
        ];
    };
    environment.systemPackages = with pkgs; [
        # gqrx # Broken
        sdrpp
        urh
        gnuradio

        # rtl_433
    ];
}
