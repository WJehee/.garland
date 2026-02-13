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
            "img.wouterjehee.com".extraConfig = ''
                reverse_proxy http://localhost:2283
            '';

            "auth.wouterjehee.com".extraConfig = ''
                reverse_proxy http://localhost:9000
            '';

            "dorusrijkers.eu".extraConfig = ''
                root * /var/www/dorusrijkers.eu
                encode gzip
                file_server
            '';
            "loodsenboekje.dorusrijkers.eu".extraConfig = ''
                reverse_proxy http://localhost:1744
            '';
        };
    };
}
