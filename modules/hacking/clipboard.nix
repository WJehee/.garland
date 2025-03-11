{ pkgs, ... }: let
    # NOTE: Can't use single quotes in these commands
    commands = ''
        nmap -sC -sV
        rcat listen -e "export TERM=xterm" -bi 8123
        ssh -L REMOTE_PORT:localhost:LOCAL_PORT user@REMOTE_IP}
    '';
    hacking_commands = pkgs.writeShellScriptBin "hacking_commands" ''
        commands=$(echo '${builtins.toString commands}')
        selected=$(echo "$commands" | wofi -d -i -p "Select a command:")
        if [ -n "$selected" ]; then
            echo "$selected" | wl-copy
        fi
    '';
in {
    environment.systemPackages = [ hacking_commands ];
}
