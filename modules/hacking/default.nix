{ pkgs, ... }: {
    imports = [
        ./clipboard.nix
        ./sdr.nix
        ./hardware.nix
    ];

    programs = {
        wireshark.enable = true;
    };
    environment.systemPackages = with pkgs; [
        nmap
        tcpdump
        caido-desktop
        wireshark
        rustcat
        git
        sqlmap

        # Discovery / fuzzing
        feroxbuster
        ffuf
        wordlists

        # Passwords
        john
        hashcat
        hashcat-utils
    ];
    environment.sessionVariables.WIRESHARK_PLUGIN_DIR = "$HOME/.local/lib/wireshark/plugins/";
    # Make hosts file writeable (by root)
    environment.etc.hosts.mode = "0644";
}
