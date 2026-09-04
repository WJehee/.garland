# Keep home-manager and stylix generated files out of $HOME
{
    flake.modules.homeManager.workstation = { config, ... }: {
        # ~/.gtkrc-2.0 -> ~/.config/gtk-2.0/gtkrc (also sets GTK2_RC_FILES)
        gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
        # ~/.Xresources; nothing loads it on Wayland but stylix generates it
        xresources.path = "${config.xdg.configHome}/X11/xresources";
        # ~/.icons; the cursor is also linked into $XDG_DATA_HOME/icons and
        # XCURSOR_PATH includes that directory
        home.pointerCursor.dotIcons.enable = false;
        # ~/.themes; only used to hand the GTK theme to flatpak apps
        stylix.targets.gtk.flatpakSupport.enable = false;
    };
}
