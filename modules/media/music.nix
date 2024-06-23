{ pkgs, ... }: {
    services = {
        mopidy = {
            enable = true;
            extensionPackages = with pkgs; [
                mopidy-mpd
                mopidy-spotify
            ];
            configuration = ''
                [core]
                cache_dir = $XDG_CACHE_DIR/mopidy
                config_dir = $XDG_CONFIG_DIR/mopidy
                data_dir = $XDG_DATA_DIR/mopidy
            '';
        };
    };
}
