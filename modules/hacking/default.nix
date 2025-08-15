{ pkgs, ... }: {
    imports = [
        ./clipboard.nix
        ./sdr.nix
        # ./hardware.nix
    ];
    programs = {
        wireshark.enable = true;
    };
    environment.systemPackages = with pkgs; [
        nmap
        tcpdump
        caido
        wireshark
        rustcat
        git
        sqlmap
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
        john
        hashcat
        hashcat-utils
    
        metasploit
        # exploitdb

        # trufflehog
        # httpx
        # gowitness
        # mitmproxy
        # snmpcheck
    ];
    environment.sessionVariables.WIRESHARK_PLUGIN_DIR = "$HOME/.local/lib/wireshark/plugins/";
    # Make hosts file writeable (by root)
    environment.etc.hosts.mode = "0644";
}
