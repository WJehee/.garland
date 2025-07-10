{ pkgs, ... }: {
    programs = {
        minipro.enable = true;
    };
    environment.systemPackages = with pkgs; [
        # SDR
        sdrpp
        urh
    
        # Reverse engineering
        binwalk
        cutter
        frida-tools

        # cantoolz
        # esptool
        # aircrack-ng
    ];
}
