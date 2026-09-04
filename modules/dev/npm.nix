{
    # NPM_CONFIG_USERCONFIG (modules/base/env.nix) points here; npm expands
    # ''${VAR} itself, so the paths stay relative to the XDG variables.
    flake.modules.homeManager.dev = { ... }: {
        xdg.configFile."npm/npmrc".text = ''
            prefix=''${XDG_DATA_HOME}/npm
            cache=''${XDG_CACHE_HOME}/npm
            init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
            logs-dir=''${XDG_STATE_HOME}/npm/logs
        '';
    };
}
