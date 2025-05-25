{ pkgs, ... }: {
    services = {
        printing.enable = true;
        printing.drivers = [
            pkgs.hplip 
        ];
        avahi.enable = true;
        avahi.nssmdns4 = true;
        avahi.openFirewall = true;
    };
    hardware.sane.enable = true;
}
