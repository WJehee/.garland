# Radicale CalDAV/CardDAV server behind caddy at cal.wouterjehee.com.
#
# Secrets, add with `just secrets <host>`:
#   radicale-htpasswd: the htpasswd file radicale authenticates against, one
#                      `user:bcrypt-hash` line per account. Generate a line
#                      with
#                        nix shell nixpkgs#apacheHttpd -c htpasswd -nB <user>
#                      and use a YAML block scalar for more than one account.
#                      The plaintext password of the user `wouter` is what
#                      the workstations store as `noctalia-caldav-password`
#                      (modules/workstation/calendar.nix).
{
    flake.modules.nixos."services/radicale" = { config, ... }: {
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
                    hosts = [ "127.0.0.1:5232" ];
                };
                auth = {
                    type = "htpasswd";
                    htpasswd_filename = config.sops.secrets."radicale-htpasswd".path;
                    htpasswd_encryption = "bcrypt";
                };
            };
        };
    };
}
