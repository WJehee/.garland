# Kodi as an appliance, the way LibreELEC and OSMC run it: no display
# server, kodi draws straight onto the KMS/DRM device through GBM and takes
# input from libinput, started on tty1 at boot as its own user. The service
# definition follows the cage kiosk module in nixpkgs
# (nixos/modules/services/wayland/cage.nix): the PAM session through
# pam_systemd is what gives the kodi user a logind seat, and with it access
# to the GPU and input devices without running as root.
#
# Ships the OSMC skin and the Jellyfin addon so the box is a client for the
# jellyfin on oleander (the media stack in wreath). Kodi keeps its own state
# (library, addon settings, skin choice) in /var/lib/kodi.
{
    flake.modules.nixos.kodi = { config, pkgs, ... }: let
        kodi = pkgs.kodi-gbm.withPackages (p: with p; [
            jellyfin
            osmc-skin
            # DRM/DASH streams, needed by most streaming addons
            inputstream-adaptive
            inputstream-ffmpegdirect
            # Browse remote shares from the file manager
            vfs-sftp
        ]);
    in {
        environment.systemPackages = [ kodi ];
        hardware.graphics.enable = true;

        users.users.kodi = {
            isSystemUser = true;
            group = "kodi";
            home = "/var/lib/kodi";
            createHome = true;
            # video and render for the DRM device, input for libinput's
            # evdev nodes, audio for direct ALSA output (there is no
            # pipewire on an appliance; kodi talks to ALSA itself)
            extraGroups = [ "video" "render" "input" "audio" ];
        };
        users.groups.kodi = { };

        systemd.services.kodi = {
            description = "Kodi media center";
            after = [
                "systemd-user-sessions.service"
                "systemd-logind.service"
                "network-online.target"
                "sound.target"
                "getty@tty1.service"
            ];
            wants = [
                "dbus.socket"
                "systemd-logind.service"
                "network-online.target"
            ];
            conflicts = [ "getty@tty1.service" ];
            before = [ "graphical.target" ];
            wantedBy = [ "graphical.target" ];
            # Restarting kodi on every rebuild would interrupt playback;
            # kodi picks up the new package when it next exits
            restartIfChanged = false;
            unitConfig.ConditionPathExists = "/dev/tty1";
            serviceConfig = {
                ExecStart = "${kodi}/bin/kodi --standalone --windowing=gbm";
                User = "kodi";
                Group = "kodi";
                # Kodi exits on "Reboot"/"Power off" from its own menu with a
                # non-zero status; systemd is what actually acts on them
                Restart = "on-failure";
                RestartSec = 3;
                UtmpIdentifier = "%n";
                UtmpMode = "user";
                TTYPath = "/dev/tty1";
                TTYReset = "yes";
                TTYVHangup = "yes";
                TTYVTDisallocate = "yes";
                StandardInput = "tty-fail";
                StandardOutput = "journal";
                StandardError = "journal";
                PAMName = "kodi";
            };
            environment.HOME = "/var/lib/kodi";
        };
        security.pam.services.kodi.text = ''
            auth    required pam_unix.so nullok
            account required pam_unix.so
            session required pam_unix.so
            session required pam_env.so conffile=/etc/pam/environment readenv=0
            session required ${config.systemd.package}/lib/security/pam_systemd.so
        '';
        # So "Reboot" and "Power off" in kodi's menu work for a plain user
        security.polkit = {
            enable = true;
            extraConfig = ''
                polkit.addRule(function(action, subject) {
                    if (subject.user == "kodi" &&
                        action.id.indexOf("org.freedesktop.login1.") == 0) {
                        return polkit.Result.YES;
                    }
                });
            '';
        };
        systemd.targets.graphical.wants = [ "kodi.service" ];
        systemd.defaultUnit = "graphical.target";

        # Remote control apps (Kore, Yatse) talk to kodi's web server on 8080
        # and its event server on 9777; both are off by default and are
        # switched on in Settings > Services > Control
        networking.firewall = {
            allowedTCPPorts = [ 8080 ];
            allowedUDPPorts = [ 9777 ];
        };
    };
}
