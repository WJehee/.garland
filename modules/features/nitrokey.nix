{
    flake.modules.nixos.nitrokey = { pkgs, lib, ... }: {
        hardware = {
            nitrokey.enable = true;
            gpgSmartcards.enable = true;
        };
        services.pcscd.enable = true;

        # expose the authentication subkey on the card as an ssh key;
        # gpg-agent replaces ssh-agent (enabled in base) and provides SSH_AUTH_SOCK
        programs.gnupg.agent.enableSSHSupport = true;
        programs.ssh.startAgent = lib.mkForce false;

        environment.systemPackages = with pkgs; [
            pynitrokey
            nitrokey-app2
            libfido2
        ];
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
