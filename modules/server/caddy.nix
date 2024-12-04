{}: {
    services.caddy = {
        enable = true;
        virtualHosts = {
            "wouterjehee.com".extraConfig = ''
                root * /var/www/wouterjehee.com
                encode gzip
                file_server
            '';
            "cal.wouterjehee.com".extraConfig = ''
                http://localhost:5232
            '';
            "ntfy.wouterjehee.com".extraConfig = ''
                reverse_proxy http://localhost:2555
            '';
            "loodsenboekje.com".extraConfig = ''
                reverse_proxy http://localhost:1744
            '';
            "dorusrijkers.club".extraConfig = ''
                root * /var/www/dorusrijkers.club
                encode gzip
                file_server
            '';
            "loodsenboekje.dorusrijkers.club".extraConfig = ''
                reverse_proxy http://localhost:1744
            '';
        };
    };
}
