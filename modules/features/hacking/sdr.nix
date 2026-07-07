{
    flake.modules.nixos.hacking = { pkgs, ... }: {
        hardware = {
            rtl-sdr.enable = true;
            hackrf.enable = true;
        };
        users = {
            groups.plugdev = {};
            users.wouter.extraGroups = [
                "plugdev"
            ];
        };
        environment.systemPackages = with pkgs; [
            gnuradio
            urh
            sdrpp
            # gqrx

            # rtl_433
            hackrf
        ];
    };
}
