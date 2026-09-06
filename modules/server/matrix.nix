# Matrix homeserver (Synapse) with mautrix bridges for Signal, WhatsApp and Discord.
#
# Matrix IDs are @user:wouterjehee.com; the server itself lives at
# matrix.wouterjehee.com. Clients and federation find it through
# /.well-known/matrix/* on wouterjehee.com, so whichever host imports this
# module must also be the one serving wouterjehee.com (or copy that block).
#
# Secrets, add with `just secrets <host>`:
#   matrix-registration-shared-secret: random string, `openssl rand -hex 32`
#
# Account creation and bridge login steps: docs/matrix.adoc
#
# Threema is deliberately absent: nixpkgs ships no Threema bridge.
{
    flake.modules.nixos."services/matrix" = { config, lib, pkgs, ... }: let
        domain = "wouterjehee.com";
        host = "matrix.${domain}";
        admin = "@wouter:${domain}";
        synapseUrl = "http://127.0.0.1:8008";

        wellKnown = path: data: ''
            handle ${path} {
                header Content-Type application/json
                header Access-Control-Allow-Origin *
                respond `${builtins.toJSON data}` 200
            }
        '';

        bridgeSettings = {
            homeserver = {
                address = synapseUrl;
                inherit domain;
            };
            bridge.permissions = {
                "*" = "relay";
                ${domain} = "user";
                ${admin} = "admin";
            };
        };
    in {
        sops.secrets."matrix-registration-shared-secret" = {};
        sops.templates."matrix-synapse-secrets.yaml" = {
            owner = "matrix-synapse";
            content = builtins.toJSON {
                registration_shared_secret = config.sops.placeholder."matrix-registration-shared-secret";
            };
        };

        services.caddy.virtualHosts = {
            "${domain}".extraConfig =
                wellKnown "/.well-known/matrix/server" { "m.server" = "${host}:443"; }
                + wellKnown "/.well-known/matrix/client" { "m.homeserver".base_url = "https://${host}"; };
            "${host}".extraConfig = ''
                reverse_proxy /_matrix/* ${synapseUrl}
                reverse_proxy /_synapse/client/* ${synapseUrl}
                respond 404
            '';
        };

        # Synapse refuses to run on a database whose collation is not "C",
        # and ensureDatabases inherits the cluster locale, so create it by hand.
        services.postgresql = {
            enable = true;
            ensureUsers = [ { name = "matrix-synapse"; } ];
        };
        systemd.services.postgresql-setup.serviceConfig.ExecStartPost = [
            (pkgs.writeShellScript "matrix-synapse-create-db" ''
                psql=${lib.getExe' config.services.postgresql.package "psql"}
                $psql -tAc "SELECT 1 FROM pg_database WHERE datname = 'matrix-synapse'" | grep -q 1 \
                    || $psql -c 'CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse" TEMPLATE template0 LC_COLLATE "C" LC_CTYPE "C"'
            '')
        ];

        services.matrix-synapse = {
            enable = true;
            extraConfigFiles = [ config.sops.templates."matrix-synapse-secrets.yaml".path ];
            settings = {
                server_name = domain;
                public_baseurl = "https://${host}";
                enable_registration = false;
                # Default listener: 127.0.0.1:8008, client + federation, x_forwarded
                max_upload_size = "100M";
                suppress_key_server_warning = true;
            };
        };

        # Bridges auto-register with Synapse; login by DM'ing the bot.
        # Signal and WhatsApp use the pure-Go Olm implementation so they don't
        # pull in the deprecated libolm. Discord still links libolm.
        services.mautrix-signal = {
            enable = true;
            package = pkgs.mautrix-signal.override { withGoolm = true; };
            settings = bridgeSettings // {
                backfill.enabled = true;
            };
        };
        services.mautrix-whatsapp = {
            enable = true;
            package = pkgs.mautrix-whatsapp.override { withGoolm = true; };
            settings = bridgeSettings // {
                backfill.enabled = true;
            };
        };
        services.mautrix-discord = {
            enable = true;
            settings = bridgeSettings;
        };
        nixpkgs.config.permittedInsecurePackages = [ "olm-3.2.16" ];
    };
}
