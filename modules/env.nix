{ pkgs, ... }: {
    environment = {
        sessionVariables = {
            XDG_CACHE_HOME = "$HOME/.cache";
            XDG_CONFIG_HOME = "$HOME/.config";
            XDG_DATA_HOME = "$HOME/.local/share";
            XDG_STATE_HOME = "$HOME/.local/state";

            GIT_EDITOR = "nvim";
            VISUAL = "nvim";
            TERMINAL = "alacritty";
            TERM = "xterm-256color";
            BROWSER = "firefox";
            
            # Clean up home
            CARGO_HOME = "$XDG_CONFIG_HOME/cargo";
            RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
            DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
            GOPATH = "$XDG_DATA_HOME/go";
            STACK_ROOT = "$XDG_DATA_HOME/stack";
            IPYTHONDIR = "$XDG_CONFIG_HOME/jupyter";
            NPM_CONFIG_USERCONFIG = "$XDG_CONFIG_HOME/npm/npmrc";
            JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";
            LEIN_HOME = "$XDG_DATA_HOME/lein";
            GHCUP_USE_XDG_DIRS = "true";
            CABAL_CONFIG = "$XDG_CONFIG_HOME/cabal/config";
            CABAL_DIR = "$XDG_CACHE_HOME/cabal";
            WGETRC = "$XDG_CONFIG_HOME/wgetrc";
            CONDARC = "$XDG_CONFIG_HOME/conda/condarc";
            GTK2_RC_FILES = "$XDG_CONFIG_HOME/gtk-2.0/gtkrc";

            GRADLE_USER_HOME = "$XDG_DATA_HOME/gradle";
            # GNUPGHOME = "$XDG_DATA_HOME/gnupg";
            WINEPREFIX = "$XDG_DATA_HOME/wineprefixes/default";

            ERRFILE = "$XDG_CACHE_HOME/X11/xsession-errors";
            ICEAUTHORITY = "$XDG_CACHE_HOME/ICEauthority";
        };
    };
}
