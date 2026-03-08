{ pkgs, ... }: {
    services.caddy.virtualHosts = {
        "wouterjehee.com".extraConfig = ''
            root * /var/www/wouterjehee.com
            encode gzip
            file_server
        '';
        "dorusrijkers.eu".extraConfig = ''
            root * /var/www/dorusrijkers.eu
            encode gzip
            file_server
        '';
        "loodsenboekje.dorusrijkers.eu".extraConfig = ''
            reverse_proxy http://localhost:1744
        '';
        "test.dorusrijkers.eu".extraConfig = ''
            reverse_proxy http://foxglove:4000
        '';
        "6767ov.dorusrijkers.eu".extraConfig = ''
            route {
                import authelia
                reverse_proxy http://foxglove:6767
            }
        '';
    };

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
