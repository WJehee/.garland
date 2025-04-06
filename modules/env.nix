{ pkgs, ... }: {
    environment = {
        sessionVariables = {
            XDG_CACHE_HOME = "$HOME/.cache";
            XDG_CONFIG_HOME = "$HOME/.config";
            XDG_DATA_HOME = "$HOME/.local/share";
            XDG_STATE_HOME = "$HOME/.local/state";

            TERMINAL = "alacritty";
            TERM = "xterm-256color";
            BROWSER = "librewolf";

            # Clean up home
            CARGO_HOME = "$XDG_CONFIG_HOME/cargo";
            RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

            PYTHON_HISTORY = "$XDG_STATE_HOME/python/history";
            PYTHONPYCACHEPREFIX = "$XDG_CACHE_HOME/python";
            PYTHONUSERBASE = "$XDG_DATA_HOME";
            CONDARC = "$XDG_CONFIG_HOME/conda/condarc";
            JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";
            IPYTHONDIR = "$XDG_CONFIG_HOME/jupyter";

            STACK_ROOT = "$XDG_DATA_HOME/stack";
            CABAL_CONFIG = "$XDG_CONFIG_HOME/cabal/config";
            CABAL_DIR = "$XDG_CACHE_HOME/cabal";
            GHCUP_USE_XDG_DIRS = "true";

            MIX_XDG = "true";
            LEIN_HOME = "$XDG_DATA_HOME/lein";
            GOPATH = "$XDG_DATA_HOME/go";
            NPM_CONFIG_USERCONFIG = "$XDG_CONFIG_HOME/npm/npmrc";
            HISTFILE = "$XDG_STATE_HOME/bash";

            WGETRC = "$XDG_CONFIG_HOME/wgetrc";
            GTK2_RC_FILES = "$XDG_CONFIG_HOME/gtk-2.0/gtkrc";
            DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
            GRADLE_USER_HOME = "$XDG_DATA_HOME/gradle";
            WINEPREFIX = "$XDG_DATA_HOME/wineprefixes/default";
            ICEAUTHORITY = "$XDG_CACHE_HOME/ICEauthority";
            GNUPGHOME = "$XDG_DATA_HOME/gnupg";
        };
    };
}
