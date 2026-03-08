{ config, ... }: {
    sops.secrets."radicale-htpasswd" = {
        owner = "radicale";
        group = "radicale";
    };

    services.caddy.virtualHosts."cal.wouterjehee.com".extraConfig = ''
        reverse_proxy http://localhost:5232
    '';

    services.radicale = {
        enable = true;
        settings = {
            server = {
                hosts = [ "0.0.0.0:5232" "[::]:5232" ];
            };
            auth = {
                type = "htpasswd";
                htpasswd_filename = config.sops.secrets."radicale-htpasswd".path;
                htpasswd_encryption = "bcrypt";
            };
        };
    };
}
