{
    flake.modules.nixos."services/gitea" = {
        services.caddy.virtualHosts."git.wouterjehee.com".extraConfig = ''
            reverse_proxy http://localhost:3001
        '';

        services.gitea = {
            enable = true;
            settings = {
                server = {
                    DOMAIN = "git.wouterjehee.com";
                    ROOT_URL = "https://git.wouterjehee.com/";
                    HTTP_ADDR = "127.0.0.1";
                    HTTP_PORT = 3001;
                };
                service = {
                    DISABLE_REGISTRATION = true;
                };
            };
        };
    };
}
