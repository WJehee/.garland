{ ... }: {
    services.caddy.virtualHosts."img.wouterjehee.com".extraConfig = ''
        reverse_proxy http://localhost:2283
    '';

    services.immich = {
        enable = true;
        mediaLocation = "/var/lib/immich";
    };
}
