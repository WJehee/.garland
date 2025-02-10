{ pkgs, ... }: {
    # TODO: make this work with wofi (#40)

    # commands = [
    #     "python2 -c 'import pty; pty.spawn("/bin/bash")'"
    #     "python3 -c 'import pty; pty.spawn("/bin/bash")'"
    #     "nmap -sC -sV"
    #     "rcat listen -e 'export TERM=xterm' -bi 8123"
    #   "ssh -L REMOTE_PORT:localhost:LOCAL_PORT user@REMOTE_IP"
    # ];
    # common_commands = pkgs.writeShellScriptBin "common_commands" ''
    # '';
}
