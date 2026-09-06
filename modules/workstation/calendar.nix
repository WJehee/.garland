# Calendars in noctalia's control center: the radicale CalDAV server on
# hemlock plus a public ICS feed. Its own feature (not part of workstation)
# because it needs host secrets, which wisteria cannot decrypt yet.
#
# Secrets to add with `just secrets <host>`:
#   noctalia-caldav-password: the radicale password for the user below
#   noctalia-storage-key:     64 hex chars, `head -c 32 /dev/urandom | xxd -p -c 64`
#
# The storage key encrypts noctalia's on-disk calendar event cache and
# clipboard history; without it both live in memory only and are lost on
# every shell restart. Keep it stable, replacing it makes existing data
# unreadable.
{
    flake.modules.nixos.calendar = {
        sops.secrets = {
            "noctalia-caldav-password".owner = "wouter";
            "noctalia-storage-key".owner = "wouter";
        };
    };

    flake.modules.homeManager.calendar = { config, osConfig, ... }:
    let
        colors = config.lib.stylix.colors.withHashtag;
        # Noctalia colors calendars per account, not per collection, so each
        # radicale collection gets its own account on the same server
        radicale = collection: color: {
            type = "caldav";
            provider = "custom";
            name = collection;
            server_url = "https://cal.wouterjehee.com/";
            username = "wouter";
            calendars = [ collection ];
            credential_source = "file";
            password_file = osConfig.sops.secrets."noctalia-caldav-password".path;
            inherit color;
        };
    in {
        programs.noctalia.settings = {
            storage = {
                key_source = "file";
                key_file = osConfig.sops.secrets."noctalia-storage-key".path;
            };
            calendar = {
                enabled = true;
                refresh_minutes = 15;
                account = {
                    personal = radicale "personal" colors.base05;  # light gray
                    scouting = radicale "scouting" colors.base0B;  # green
                    work = radicale "work" colors.base03;          # dark gray
                    social = radicale "social" colors.base0E;      # purple
                };
            };
        };
    };
}
