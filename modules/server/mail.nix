# Self-hosted mail with Simple NixOS Mailserver (SNM): postfix, dovecot,
# rspamd (spam filtering and DKIM signing) and a local resolver, all
# declared here. Mail for wouterjehee.com is delivered to lldap users.
#
# Accounts come from lldap (modules/server/lldap.nix) rather than static
# entries, so the same directory that backs authelia decides who has a
# mailbox: membership of the lldap group `mail`, and the user's mail
# attribute is the address. lldap never exposes password hashes, so dovecot
# verifies passwords by binding as the user (SNM does this when the
# password attribute is null). Maildirs are keyed on entryUUID, which lldap
# serves under whatever spelling the client asks for.
#
# Certificate: caddy owns ports 80 and 443 on the host, so the mail
# certificate comes from the NixOS ACME module with an HTTP-01 webroot
# challenge that caddy serves. The caddy site is declared as http:// on
# purpose: a plain hostname would make caddy order a second certificate for
# the same name and redirect the challenge request to HTTPS.
# Postfix and dovecot read the key as root, so no group changes are needed.
#
# Secret, add with `just secrets <host>`:
#   mail-ldap-bind-password: password of the lldap user `mailserver`,
#   without a trailing newline (SNM binds with the file verbatim)
#
# lldap runtime state, DNS records and client settings: docs/mail.adoc
{ inputs, ... }: {
    flake.modules.nixos."services/mail" = { config, ... }: let
        domain = "wouterjehee.com";
        fqdn = "mail.${domain}";
        webroot = "/var/lib/acme/acme-challenge";
        baseDn = "dc=wouterjehee,dc=com";
        mailGroup = "memberOf=cn=mail,ou=groups,${baseDn}";
    in {
        imports = [ inputs.nixos-mailserver.nixosModules.default ];

        sops.secrets."mail-ldap-bind-password" = {};

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
            ldap = {
                enable = true;
                # Same host as lldap, so plain LDAP over loopback
                uris = [ "ldap://127.0.0.1:3890" ];
                bind = {
                    dn = "uid=mailserver,ou=people,${baseDn}";
                    passwordFile = config.sops.secrets."mail-ldap-bind-password".path;
                };
                base = "ou=people,${baseDn}";
                # lldap keeps every user directly under ou=people
                scope = "one";
                # Every lookup is gated on the mail group, not just login:
                # otherwise any lldap user could send as their mail attribute
                # through this server
                postfix.filter = "(&(${mailGroup})(mail=%s))";
                dovecot = {
                    passFilter = "(&(${mailGroup})(uid=%{user}))";
                    userFilter = "(&(${mailGroup})(|(mail=%{user})(uid=%{user})))";
                };
            };

            # RFC 2142 role addresses. `aliases` only works for static
            # accounts (postfix authorises senders by login identity), so
            # these are forwards: mail arrives, but cannot be sent as
            forwards = {
                "postmaster@${domain}" = "wouter@${domain}";
                "abuse@${domain}" = "wouter@${domain}";
            };
        };
    };
}
