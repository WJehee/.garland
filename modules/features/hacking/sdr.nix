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
            # gnuradio
            urh
            # TODO: re-enable sdrpp and gqrx once nixos-unstable includes
            # https://github.com/NixOS/nixpkgs/pull/568744 (soapyuhd bumped to
            # an upstream revision that builds against uhd 4.11). Both pull in
            # soapysdr-with-plugins, whose soapyuhd plugin fails to compile on
            # the current pin. Neither is needed for the rtl-sdr or hackrf.
            # sdrpp
            # gqrx

            # rtl_433
            hackrf
        ];
    };
}
