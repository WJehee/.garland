# One clipboard for everything: the Wayland clipboard is the single source of
# truth and every tool reads from and writes to it. Neovim's side of this
# (unnamedplus, OSC 52 over ssh) lives in base/nixvim.nix since it applies to
# servers as well.
{
    flake.modules.homeManager.workstation = {
        # Clipboard history: `wl-paste --watch cliphist store` as two systemd
        # user services (text and images) on graphical-session.target. Without
        # the watcher the picker below has nothing to list.
        services.cliphist.enable = true;

        programs.alacritty.settings = {
            # Selecting text in the terminal also puts it on the clipboard, so
            # the primary selection and the clipboard never diverge (Hyprland
            # has middle-click paste disabled anyway)
            selection.save_to_clipboard = true;
            # Remote programs (nvim over ssh) may write the clipboard through
            # OSC 52 but not read it: a read would hand whatever was last
            # copied locally to any process on the remote host
            terminal.osc52 = "OnlyCopy";
        };
    };

    flake.modules.homeManager.hyprland = { lib, ... }: {
        wayland.windowManager.hyprland.settings.bind = [
            # Pick an entry from the history and make it the current clipboard
            {
                _args = [
                    (lib.generators.mkLuaInline ''mainMod .. " + V"'')
                    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy")'')
                ];
            }
        ];
    };
}
