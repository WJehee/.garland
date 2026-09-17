# Self-hosted mail with Simple NixOS Mailserver (SNM): postfix, dovecot,
# rspamd (spam filtering and DKIM signing) and a local resolver, all
# declared here. Mail for wouterjehee.com lands in one mailbox.
#
# Certificate: caddy owns ports 80 and 443 on the host, so the mail
# certificate comes from the NixOS ACME module with an HTTP-01 webroot
# challenge that caddy serves. The caddy site is declared as http:// on
# purpose: a plain hostname would make caddy order a second certificate for
# the same name and redirect the challenge request to HTTPS.
# Postfix and dovecot read the key as root, so no group changes are needed.
#
# Secret, add with `just secrets <host>`:
#   mail-password-hash-wouter: `nix run nixpkgs#mkpasswd -- -s`
#
# DNS records (MX, SPF, DKIM, DMARC, PTR) and client settings: docs/mail.adoc
{ inputs, ... }: {
    flake.modules.nixos."services/mail" = { config, ... }: let
        domain = "wouterjehee.com";
        fqdn = "mail.${domain}";
        webroot = "/var/lib/acme/acme-challenge";
    in {
        imports = [ inputs.nixos-mailserver.nixosModules.default ];

        sops.secrets."mail-password-hash-wouter" = {};

        security.acme = {
            acceptTerms = true;
            defaults.email = "postmaster@${domain}";
            certs.${fqdn}.webroot = webroot;
        };
        services.caddy.virtualHosts."http://${fqdn}".extraConfig = ''
            root * ${webroot}
            file_server
        '';

        mailserver = {
            enable = true;
            # Initial value from the SNM setup guide. Raise it only when an
            # assertion asks for it, after doing the migration it names:
            # https://nixos-mailserver.readthedocs.io/en/latest/migrations.html
            stateVersion = 5;
            inherit fqdn;
            domains = [ domain ];
            x509.useACMEHost = fqdn;

            # Defaults keep only IMAPS (993) and submission over implicit TLS
            # (465); plain IMAP and STARTTLS submission stay off
            accounts."wouter@${domain}" = {
                hashedPasswordFile = config.sops.secrets."mail-password-hash-wouter".path;
                # RFC 2142 role addresses; DMARC and abuse reports for the
                # domain end up here
                aliases = [
                    "postmaster@${domain}"
                    "abuse@${domain}"
                ];
            };
        };
    };
}
