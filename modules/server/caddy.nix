{ ... }: {
    services.caddy = {
        enable = true;
        virtualHosts = {
            "wouterjehee.com".extraConfig = ''
                root * /var/www/wouterjehee.com
                encode gzip
                file_server
            '';
            "cal.wouterjehee.com".extraConfig = ''
                reverse_proxy http://localhost:5232
            '';
            "dorusrijkers.club".extraConfig = ''
                root * /var/www/dorusrijkers.club
                encode gzip
                file_server
            '';
            "loodsenboekje.dorusrijkers.club".extraConfig = ''
                reverse_proxy http://localhost:1744
            '';
            "royale.dorusrijkers.club".extraConfig = ''
                reverse_proxy http://rusty-laptop.tailff8332.ts.net:4000
            '';
            "berentocht.dorusrijkers.club".extraConfig = ''
                reverse_proxy http://rusty-laptop.tailff8332.ts.net:4000
            '';
            "feest.dorusrijkers.club".extraConfig = ''
                reverse_proxy http://rusty-laptop.tailff8332.ts.net:8080
            '';
        };
    };
}
