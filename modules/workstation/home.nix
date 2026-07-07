{
    flake.modules.homeManager.workstation = { ... }: {
        dconf.settings."org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
        };
        programs.home-manager.enable = true;
    };
}
