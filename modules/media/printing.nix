{ pkgs, ... }: {
    services = {
        printing.enable = true;
        printing.drivers = [
            pkgs.hplip 
        ];
        avahi.enable = true;
        avahi.nssmdns = true;
        avahi.openFirewall = true;
    };
    hardware.sane.enable = true;
}
