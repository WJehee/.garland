{ pkgs, ... }: {
    programs = {
        wireshark.enable = true;
        # minipro.enable = true;
    };
    environment.systemPackages = with pkgs; [
        nmap
        masscan
        tcpdump
        caido
        wireshark
        # responder
        # netexec
        # sqlmap
        # dsniff
        # bettercap

        # DNS
        # dig
        # dnschef
        # massdns

        # Discovery / fuzzing
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

        # metasploit
        # package for nix? 
        # https://github.com/AzeemIdrisi/PhoneSploit-Pro
        # https://github.com/PentestPad/subzy

        # Finding secrets
        # trufflehog

        # httpx
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
