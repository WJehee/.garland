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
{ config, ... }: let
    keys = import ../_ssh-keys.nix;
    handle = ".ssh/id_ed25519_sk_rk_wouter@nitrokey-1";
in {
    flake.modules.nixos.workstation.imports = [ config.flake.modules.nixos.nitrokey ];
    flake.modules.homeManager.workstation.imports = [ config.flake.modules.homeManager.nitrokey ];

    flake.modules.nixos.nitrokey = { pkgs, ... }: {
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
        '';
    };

    # Sign git and jj commits with the token. Both point at the handle file
    # rather than the public key: ssh-keygen only consults ssh-agent when
    # given a public key, and the handle is never loaded into the agent.
    # jj signs on push instead of on every rewrite because each signature
    # needs a touch, and jj rewrites descendants constantly.
    flake.modules.homeManager.nitrokey = { config, pkgs, ... }: let
        handlePath = "${config.home.homeDirectory}/${handle}";
        # The backup key is listed so its signatures verify should the
        # primary ever be replaced by it.
        allowedSigners = pkgs.writeText "allowed_signers" ''
            wouter@wouterjehee.com ${keys.nitrokey}
            wouter@wouterjehee.com ${keys.nitrokey-backup}
        '';
    in {
        programs.git.settings = {
            gpg.format = "ssh";
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
