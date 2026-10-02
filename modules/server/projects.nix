{ inputs, ... }: let
    # Read from blotter's secretspec.toml, the same list its module asserts
    # against, so a secret added there only needs a value, not a garland edit.
    blotterSecrets = builtins.attrNames
        (builtins.fromTOML (builtins.readFile "${inputs.blotter}/secretspec.toml")).profiles.default;
in {
    flake.modules.nixos."services/projects" = { config, lib, pkgs, ... }: {
        imports = [
            inputs.loodsenboekje.nixosModules.loodsenboekje
            inputs.galeharp.nixosModules.default
            inputs.blotter.nixosModules.default
        ];

        services.caddy.virtualHosts = {
            "wouterjehee.com".extraConfig = ''
                root * /var/www/wouterjehee.com
                encode gzip
                file_server
            '';
            "galeharp.wouterjehee.com".extraConfig = ''
                root * /var/www/galeharp
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
            "royale.dorusrijkers.eu".extraConfig = ''
                reverse_proxy http://localhost:${toString config.services.blotter.port}
            '';
        };

        # Website deployment
        environment.systemPackages = with pkgs; [ rsync ];
        users.users.decree = {
            isSystemUser = true;
            group = "decree";
            shell = "${pkgs.bash}/bin/bash";
            openssh.authorizedKeys.keys = let
                keys = import ../_ssh-keys.nix;
                restrict = key: ''command="${pkgs.rrsync}/bin/rrsync /var/www/wouterjehee.com",restrict ${key}'';
            in [
                # Key defined in Github secrets
                (restrict "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9Ak2oGjRlLkDPHwm8u59i3NkyBIQ/6r9KpkDt1jbbz wouter@foxglove")
                (restrict keys.nitrokey)
                (restrict keys.nitrokey-backup)
            ];
        };
        users.groups.decree = {};
        systemd.tmpfiles.rules = [
            "d /var/www/wouterjehee.com 0755 decree decree -"
        ];

        # Loodsenboekje
        services.loodsenboekje.enable = true;

        # Galeharp
        services.galeharp = {
            enable = true;
            # The module's own default reads the deprecated pkgs.system and
            # emits an evaluation warning; an explicit package skips it.
            package = inputs.galeharp.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };

        # Blotter
        services.blotter = {
            enable = true;
            host = "royale.dorusrijkers.eu";
            package = inputs.blotter.packages.${pkgs.stdenv.hostPlatform.system}.default;
            secretFiles = lib.genAttrs blotterSecrets
                (name: config.sops.secrets."blotter/${name}".path);
        };
        # Values live under a `blotter:` map in secrets/hemlock.yaml (sops-nix
        # treats the slash as nesting). They stay root owned because the
        # module hands them to the service through systemd's LoadCredential.
        sops.secrets = lib.genAttrs (map (name: "blotter/${name}") blotterSecrets) (_: {});
    };
}
