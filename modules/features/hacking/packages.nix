{
    flake.modules.nixos.hacking = { pkgs, ... }: {
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
            # cewl            # Custom wordlist generator

            # Passwords
            # john  # temporarily disabled: upstream bleeding-jumbo hash mismatch in nixpkgs
            # hashcat
            # hashcat-utils

            # Forensics
            # sleuthkit
        ];
        environment.sessionVariables.WIRESHARK_PLUGIN_DIR = "$HOME/.local/lib/wireshark/plugins/";
        # Make hosts file writeable (by root)
        environment.etc.hosts.mode = "0644";
    };
}
