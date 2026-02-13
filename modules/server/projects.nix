{ pkgs, ... }: {
    # Website deployment
    environment.systemPackages = with pkgs; [ rsync ];
    users.users.decree = {
        isSystemUser = true;
        group = "decree";
        shell = "${pkgs.bash}/bin/bash";
        openssh.authorizedKeys.keys = [
            # Key defined in Github secrets
            ''command="${pkgs.rrsync}/bin/rrsync /var/www/wouterjehee.com",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9Ak2oGjRlLkDPHwm8u59i3NkyBIQ/6r9KpkDt1jbbz wouter@foxglove''
        ];
    };
    users.groups.decree = {};
    systemd.tmpfiles.rules = [
        "d /var/www/wouterjehee.com 0755 decree decree -"
    ];

    # Loodsenboekje
    services.loodsenboekje.enable = true;
}
