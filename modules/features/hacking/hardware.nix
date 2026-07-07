{
    flake.modules.nixos.hacking = { pkgs, ... }: {
        programs = {
            # minipro.enable = true;
        };
        environment.systemPackages = with pkgs; [
            # Reverse engineering
            binwalk
            # cutter
            frida-tools

            # cantoolz
            # esptool
            # aircrack-ng
        ];
    };
}
