{ lib, pkgs, vars, config, ... }: {
    environment.systemPackages = with pkgs; [
        ncmpcpp
        mpc
        mpd
    ];

    services.mpd = {
        enable = true;
        user = "wouter";
        settings = {
            music_directory = "/home/wouter/Music";
            audio_output = [
                {
                    type = "pipewire";
                    name = "PipeWire";
                }
            ];
        };
    };
    systemd.services.mpd.environment = {
        XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.wouter.uid}";
    };
}
