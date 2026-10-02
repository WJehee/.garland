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
            git-dumper       # Dump a git repo from an exposed .git directory
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
