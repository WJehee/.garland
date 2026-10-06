# Nitrokey 3 as the SSH and commit-signing key.
#
# The key is a FIDO2 resident credential (ssh-keygen -t ed25519-sk -O resident)
# rather than an OpenPGP card key: an OpenPGP card refuses to sign or
# authenticate without a PIN, while a FIDO2 credential only asks for a touch.
# That also means no gpg-agent in the SSH path; ssh and ssh-keygen talk to the
# token directly through libfido2. The FIDO2 PIN exists only because the
# standard demands one for creating and listing resident credentials; daily
# use never asks for it.
#
# FIDO2 tokens do not store the private key, they store (for resident
# credentials) a handle that only the token can turn back into the key. ssh
# needs that handle as a file, so every machine enrolls once, with the token
# plugged in:
#   cd ~/.ssh && ssh-keygen -K
# which asks the PIN and writes id_ed25519_sk_rk_<username stored on the token>,
# the file everything below points at. The backup token holds its own credential
# under its own username; swapping it in means pointing `handle` at that file.
# Until a machine is enrolled, ssh falls back to its other identities and git/jj
# refuse to sign.
{ config, lib, ... }: let
    keys = import ../_ssh-keys.nix;
    handle = ".ssh/id_ed25519_sk_rk_wouter@nitrokey-1";
    # Announce a pending touch: on the terminal when the calling process has
    # one, otherwise as a desktop notification (a GUI client or editor plugin
    # invoking git, a process without a controlling tty). Arguments: a short
    # message and an optional detail.
    #
    # The terminal write first returns to column 0 and erases the line: the
    # caller may have left an unterminated progress line on screen (jj prints
    # "Signing <id>" without a newline while signing on push and erases it
    # afterwards), and writing after it glued the message to that line.
    # Erasing it costs nothing, since the caller would have erased it anyway,
    # and jj's own erase then hits the empty line left behind.
    announce = pkgs: pkgs.writeShellScript "nitrokey-announce" ''
        { printf '\r\033[K%s\n' "$1''${2:+ ($2)}" > /dev/tty; } 2>/dev/null \
            || ${lib.getExe pkgs.libnotify} --expire-time=15000 Nitrokey "$1''${2:+: $2}" 2>/dev/null \
            || true
    '';
in {
    flake.modules.nixos.workstation.imports = [ config.flake.modules.nixos.nitrokey ];
    flake.modules.homeManager.workstation.imports = [ config.flake.modules.homeManager.nitrokey ];

    flake.modules.nixos.nitrokey = { pkgs, ... }: let
        # ssh announces a touch ("Confirm user presence for key ...") on
        # stderr only when stderr is a terminal. Otherwise it runs SSH_ASKPASS
        # with SSH_ASKPASS_PROMPT=none and the message as argument, and if
        # that is unset or missing the token just blinks unnoticed. jj is the
        # main victim: it captures git's stderr to parse progress, so the
        # touch for the push itself (after the one for signing) was never
        # shown. The askpass is also what ssh falls back to for passphrases
        # and host key confirmations without a terminal; there is no sane
        # way to answer those from here, so they fail like they did before,
        # just with a notification saying why.
        askpass = pkgs.writeShellScript "nitrokey-askpass" ''
            if [ "$SSH_ASKPASS_PROMPT" = none ]; then
                exec ${announce pkgs} "Touch the Nitrokey" "$1"
            fi
            ${lib.getExe pkgs.libnotify} --expire-time=15000 ssh "No terminal to ask: $1" 2>/dev/null
            exit 1
        '';
        # When stderr is a terminal ssh prints the touch prompt there and
        # never consults the askpass, which is what happens during a deploy:
        # the prompt scrolls by in the middle of deploy-rs output, possibly
        # minutes after the command was typed. This Match exec runs before
        # every connection to a deploy node and sends a desktop notification,
        # unless the multiplexing master from modules/base/ssh.nix is alive,
        # in which case the connection needs no touch. The check uses
        # -F /dev/null so it does not read this config and re-trigger the
        # Match. The control socket path must stay in sync with ssh.nix.
        touchNotify = pkgs.writeShellScript "nitrokey-touch-notify" ''
            ${pkgs.openssh}/bin/ssh -F /dev/null -S "$1" -O check x >/dev/null 2>&1 && exit 0
            ${lib.getExe pkgs.libnotify} --expire-time=15000 Nitrokey "Touch the Nitrokey to connect to $2" 2>/dev/null
            exit 0
        '';
        # Delivered through an Include rather than inline in extraConfig: a
        # Match block extends to the next Host or Match line, so inline it
        # would capture whatever another module appends after it (merge
        # order is not under our control), whereas a block in an included
        # file ends with that file.
        touchNotifyConfig = pkgs.writeText "nitrokey-touch-notify.conf" (lib.concatStrings
            (lib.mapAttrsToList (name: node: ''
                Match host ${name},${node.hostname} exec "${touchNotify} ~/.ssh/control-${name} ${name}"
            '') config.flake.deploy.nodes));
    in {
        hardware.nitrokey.enable = true;
        services.pcscd.enable = true;

        environment.systemPackages = with pkgs; [
            pynitrokey
            nitrokey-app2
            libfido2
        ];

        # Offer the token's key for every connection. ssh-keygen -K does not
        # use one of the default identity names, so ssh has to be told.
        programs.ssh.extraConfig = ''
            IdentityFile ~/${handle}
            Include ${touchNotifyConfig}
        '';
        programs.ssh.enableAskPassword = true;
        programs.ssh.askPassword = "${askpass}";
    };

    # Sign git and jj commits with the token. Both point at the handle file
    # rather than the public key: ssh-keygen only consults ssh-agent when
    # given a public key, and the handle is never loaded into the agent.
    # jj signs on push instead of on every rewrite because each signature
    # needs a touch, and jj rewrites descendants constantly.
    flake.modules.homeManager.nitrokey = { config, lib, pkgs, ... }: let
        handlePath = "${config.home.homeDirectory}/${handle}";
        # The backup key is listed so its signatures verify should the
        # primary ever be replaced by it.
        allowedSigners = pkgs.writeText "allowed_signers" ''
            wouter@wouterjehee.com ${keys.nitrokey}
            wouter@wouterjehee.com ${keys.nitrokey-backup}
        '';
        # Unlike ssh, `ssh-keygen -Y sign` does not announce the touch at all
        # (its signing path has no notifier, so SSH_ASKPASS does not help
        # either), and git and jj capture its stderr anyway. This wrapper
        # announces the touch itself before handing over to ssh-keygen.
        sshKeygen = pkgs.writeShellScriptBin "ssh-keygen-touch" ''
            if [ "$1" = "-Y" ] && [ "$2" = "sign" ]; then
                ${announce pkgs} "Touch the Nitrokey to sign"
            fi
            exec ${pkgs.openssh}/bin/ssh-keygen "$@"
        '';
    in {
        programs.git.settings = {
            gpg.format = "ssh";
            gpg.ssh.program = lib.getExe sshKeygen;
            gpg.ssh.allowedSignersFile = "${allowedSigners}";
            user.signingkey = handlePath;
            commit.gpgsign = true;
            tag.gpgsign = true;
        };
        programs.jujutsu.settings = {
            signing = {
                backend = "ssh";
                key = handlePath;
                behavior = "drop";
                backends.ssh.program = lib.getExe sshKeygen;
                backends.ssh.allowed-signers = "${allowedSigners}";
            };
            git.sign-on-push = true;
        };
    };

    # FIDO2 LUKS unlock with the Nitrokey. Only the systemd initrd implements
    # fido2 unlocking, so importing this switches stage 1 to systemd.
    #
    # Per host, enroll the key into the LUKS header:
    #   systemd-cryptenroll --fido2-device=auto /dev/<luks-partition>
    # and tell the initrd to try it:
    #   boot.initrd.luks.devices.<name>.crypttabExtraOpts = [ "fido2-device=auto" ];
    flake.modules.nixos."nitrokey/luks" = {
        boot.initrd.systemd.enable = true;
        # make sure usb hid devices work before the unlock prompt
        boot.initrd.availableKernelModules = [ "usbhid" "hid_generic" ];
    };
}
