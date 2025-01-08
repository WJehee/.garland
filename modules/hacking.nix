{ pkgs, ... }: {
    programs = {
        wireshark.enable = true;
        # minipro.enable = true;
    };
    environment.systemPackages = with pkgs; [
        # Network
        nmap
        tcpdump
        caido
        wireshark
        # masscan

        # DNS
        # dig
        # dnschef
        # massdns

        # Discovery
        feroxbuster
        ffuf

        # Wordlists
        wordlists
        # cewl

        # Passwords
        john
        hashcat
        hashcat-utils
    
        # Reverse engineering
        # cutter
        # frida-tools

        # Firmware
        binwalk

        # Finding secrets
        # trufflehog

        # httpx
        # sqlmap
        # gowitness
        # mitmproxy
        # cantoolz
        # esptool
        # aircrack-ng
    ];
    environment.sessionVariables.WIRESHARK_PLUGIN_DIR = "$HOME/.local/lib/wireshark/plugins/";
    # Make hosts file writeable (by root)
    environment.etc.hosts.mode = "0644";
}
