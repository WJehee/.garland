{ pkgs, ... }: {
    imports = [
        ./clipboard.nix
    ];
    programs = {
        wireshark.enable = true;
        # minipro.enable = true;
    };
    environment.systemPackages = with pkgs; [
        nmap
        tcpdump
        caido
        wireshark
        rustcat
        git
        # masscan
        # responder
        # netexec
        # sqlmap
        # dsniff
        # bettercap
        # katana

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
        # john
        # hashcat
        # hashcat-utils
    
        # Reverse engineering
        # cutter
        # frida-tools

        # Firmware
        # binwalk

        # metasploit
        # exploitdb

        # package for nix? 
        # https://github.com/AzeemIdrisi/PhoneSploit-Pro
        # https://github.com/PentestPad/subzy

        # trufflehog
        # httpx
        # gowitness
        # mitmproxy
        # cantoolz
        # esptool
        # aircrack-ng
        # snmpcheck
    ];
    environment.sessionVariables.WIRESHARK_PLUGIN_DIR = "$HOME/.local/lib/wireshark/plugins/";
    # Make hosts file writeable (by root)
    environment.etc.hosts.mode = "0644";
}
