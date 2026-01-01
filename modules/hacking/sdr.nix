{ pkgs, ... }: {
    hardware.rtl-sdr.enable = true;
    users = {
        groups.plugdev = {};
        users.wouter.extraGroups = [
            "plugdev"
        ];
    };
    environment.systemPackages = with pkgs; [
        # sdrpp
        gqrx
        urh
        gnuradio

        # rtl_433
    ];
}
