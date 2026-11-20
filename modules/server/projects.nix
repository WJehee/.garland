# My own projects hosted on the server: the static sites, loodsenboekje,
# galeharp and blotter.
#
# Secrets, add with `just secrets <host>`:
#   blotter/<NAME>: one entry for every secret in the `default` profile of
#                   blotter's secretspec.toml (in the blotter repository,
#                   which also describes each value). They are nested under
#                   one map, not written with a slash:
#                     blotter:
#                         <NAME>: <value>
#                         <OTHER_NAME>: <value>
#                   The list is read from that file at evaluation time, so a
#                   secret added to blotter shows up here as a missing key
#                   after the next flake update.
{ inputs, ... }: let
    # Read from blotter's secretspec.toml, the same list its module asserts
    # against, so a secret added there only needs a value, not a garland edit.
    blotterSecrets = builtins.attrNames
        (builtins.fromTOML (builtins.readFile "${inputs.blotter}/secretspec.toml")).profiles.default;
in {
    flake.modules.nixos."services/projects" = { config, lib, pkgs, ... }: let
        # The front page of dorusrijkers.eu lists every subdomain that Caddy
        # serves on this host, whichever module declared the virtual host, so
        # a service that is added or removed shows up or disappears there
        # with the same deploy. Reading the attribute names of
        # services.caddy.virtualHosts from inside a definition of that same
        # option does not recurse: the names only depend on the keys of the
        # definitions, never on their values.
        landingDomain = "dorusrijkers.eu";
        # Display names by subdomain label. A subdomain without an entry is
        # listed under its bare label, so forgetting one here degrades the
        # page instead of failing the build.
        landingTitles = {
            loodsenboekje = "Loodsen Boekje";
            royale = "Dr. Royale";
        };
        # Subdomains that are infrastructure rather than a project to visit.
        landingHidden = [ "auth" ];
        landingEntries = lib.pipe (builtins.attrNames config.services.caddy.virtualHosts) [
            (builtins.filter (lib.hasSuffix ".${landingDomain}"))
            (map (lib.removeSuffix ".${landingDomain}"))
            (builtins.filter (label: !builtins.elem label landingHidden))
            (map (label: {
                host = "${label}.${landingDomain}";
                url = "https://${label}.${landingDomain}";
                title = landingTitles.${label} or label;
            }))
            (lib.sort (a: b: lib.toLower a.title < lib.toLower b.title))
        ];
        # Styled after decree (https://github.com/WJehee/decree), the site
        # behind wouterjehee.com: its default dark theme, with the project
        # list laid out like the "recent writing" list on its front page.
        # Decree builds its stylesheet with Tailwind; this page has no build
        # step, so the handful of rules it needs are written out by hand with
        # the values of decree's theme tokens. A restyle of decree therefore
        # does not carry over by itself and has to be repeated here.
        landingPage = pkgs.writeTextDir "index.html" ''
            <!DOCTYPE html>
            <html lang="nl">
                <head>
                    <title>Dorusrijkers.eu</title>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <link rel="preconnect" href="https://api.fontshare.com" crossorigin>
                    <link rel="stylesheet" href="https://api.fontshare.com/v2/css?f[]=satoshi@400,500,700,900&display=swap">
                    <style>
                        :root {
                            color-scheme: dark;
                            --zinc-100: oklch(96.7% .001 286.375);
                            --zinc-200: oklch(92% .004 286.32);
                            --zinc-400: oklch(70.5% .015 286.067);
                            --zinc-500: oklch(55.2% .016 285.938);
                            --zinc-600: oklch(44.2% .017 285.786);
                            --zinc-800: oklch(27.4% .006 286.033);
                            --zinc-950: oklch(14.1% .005 285.823);
                        }
                        *, ::before, ::after { box-sizing: border-box; margin: 0; padding: 0; }
                        html { line-height: 1.5; -webkit-text-size-adjust: 100%; }
                        body {
                            display: flex;
                            flex-direction: column;
                            min-height: 100vh;
                            font-family: "Satoshi", "Helvetica", sans-serif;
                            background: var(--zinc-950);
                            color: var(--zinc-200);
                        }
                        a { color: inherit; text-decoration: inherit; transition: color .15s cubic-bezier(.4, 0, .2, 1); }
                        .container { width: 100%; margin-inline: auto; padding-inline: 1.5rem; }
                        @media (min-width: 40rem) { .container { max-width: 40rem; } }
                        @media (min-width: 48rem) { .container { max-width: 48rem; } }
                        @media (min-width: 64rem) { .container { max-width: 64rem; } }
                        @media (min-width: 80rem) { .container { max-width: 80rem; } }
                        @media (min-width: 96rem) { .container { max-width: 96rem; } }
                        nav {
                            position: sticky;
                            top: 0;
                            z-index: 50;
                            background: color-mix(in oklab, var(--zinc-950) 80%, transparent);
                            -webkit-backdrop-filter: blur(12px);
                            backdrop-filter: blur(12px);
                            border-bottom: 1px solid var(--zinc-800);
                        }
                        nav .container { display: flex; align-items: center; height: 4rem; }
                        nav a { font-size: 1.25rem; font-weight: 700; letter-spacing: -.025em; color: var(--zinc-100); }
                        nav a:hover { color: var(--zinc-400); }
                        main { flex: 1; padding-block: 4rem; animation: .5s ease-out fade-in; }
                        @keyframes fade-in {
                            from { opacity: 0; transform: translateY(10px); }
                            to { opacity: 1; transform: none; }
                        }
                        @media (prefers-reduced-motion: reduce) { main { animation: none; } }
                        #hero { margin-bottom: 6rem; }
                        @media (min-width: 48rem) { #hero { margin-bottom: 8rem; } }
                        h1 { font-size: 3.75rem; line-height: 1; font-weight: 700; margin-bottom: 1.5rem; overflow-wrap: anywhere; }
                        @media (max-width: 40rem) { h1 { font-size: 2.5rem; } }
                        p { font-size: 1.125rem; line-height: 1.625; max-width: 42rem; }
                        h2 { font-size: 1.5rem; line-height: calc(2 / 1.5); font-weight: 700; color: var(--zinc-100); margin-bottom: 1.5rem; }
                        ul { list-style: none; }
                        li { border-bottom: 1px solid var(--zinc-800); padding-bottom: 1rem; }
                        li + li { margin-top: 1rem; }
                        li a { display: flex; align-items: baseline; gap: 1rem; }
                        li .title {
                            font-size: 1.125rem;
                            font-weight: 700;
                            color: var(--zinc-100);
                            min-width: 0;
                            overflow: hidden;
                            text-overflow: ellipsis;
                            white-space: nowrap;
                            transition: inherit;
                        }
                        li .host { margin-left: auto; flex-shrink: 0; color: var(--zinc-500); transition: inherit; }
                        li a:hover .title { color: var(--zinc-400); }
                        li a:hover .host { color: var(--zinc-600); }
                        @media (max-width: 40rem) { li .host { display: none; } }
                    </style>
                </head>
                <body>
                    <nav>
                        <div class="container">
                            <a href="/">Dorusrijkers.eu</a>
                        </div>
                    </nav>
                    <main>
                        <section id="hero">
                            <div class="container">
                                <h1>Dorusrijkers.eu</h1>
                                <p>
                                    Op deze site vind je diverse mysterieuze projecten.
                                </p>
                            </div>
                        </section>
                        <section>
                            <div class="container">
                                <h2>Projecten</h2>
                                <ul>
            ${lib.concatMapStringsSep "\n" (entry:
                "                        <li><a href=\"${entry.url}\"><span class=\"title\">${lib.escapeXML entry.title}</span><span class=\"host\">${entry.host}</span></a></li>"
            ) landingEntries}
                                </ul>
                            </div>
                        </section>
                    </main>
                </body>
            </html>
        '';
    in {
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

            # Only the front page is generated. Every other path still comes
            # from /var/www/dorusrijkers.eu, so files uploaded there by hand
            # keep working; an index.html in that directory is shadowed.
            "${landingDomain}".extraConfig = ''
                encode gzip
                @landing path / /index.html
                handle @landing {
                    root * ${landingPage}
                    rewrite * /index.html
                    file_server
                }
                handle {
                    root * /var/www/dorusrijkers.eu
                    file_server
                }
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
