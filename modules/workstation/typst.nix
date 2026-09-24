# Typst in the editor: the tinymist language server (with typstyle as its
# formatter) and a live preview. The compiler itself is not installed here;
# like cargo and rustc it comes from each project's devenv (templates/typst),
# so the document pins its own typst version. Tinymist bundles a compiler
# for diagnostics and the preview, so the editor keeps working without a
# dev shell. It is workstation config rather than a per-host feature for the
# same reason the other language servers are: it enables nothing until a
# .typ file is opened.
#
# Preview: `:TypstPreviewToggle` (<leader>tp) starts tinymist's preview
# server from neovim and opens it in a chromium app window (no tabs, no
# address bar). The preview follows the cursor and clicking the document
# jumps the editor there. Placement comes from the master layout: the
# terminal is the master tile and new windows join the stack on the right,
# so the preview lands beside the editor without a dedicated rule; the
# Hyprland rule below only keeps focus in the editor.
{
    flake.modules.nixos.workstation = { lib, pkgs, ... }: {
        programs.nixvim = {
            plugins.lsp.servers.tinymist = {
                enable = true;
                settings = {
                    formatterMode = "typstyle";
                    # Recompile on every keystroke instead of on save, so the
                    # preview and diagnostics follow the buffer.
                    compileStatus = "enable";
                };
            };

            plugins.typst-preview = {
                enable = true;
                # %s is replaced with the preview URL; the plugin runs the
                # string through a shell. Chromium is referenced by store path
                # rather than PATH so the preview keeps working inside nix
                # shells that shadow it.
                settings.open_cmd = "${lib.getExe pkgs.chromium} --app=%s";
            };

            keymaps = [
                {
                    mode = "n";
                    key = "<leader>tp";
                    action = "<cmd>TypstPreviewToggle<CR>";
                    options.desc = "Toggle typst preview";
                }
            ];
        };
    };

    flake.modules.homeManager.hyprland = { ... }: {
        wayland.windowManager.hyprland.settings.window_rule = [
            # Chromium ignores --class for --app windows on Wayland and
            # derives the app id from the URL and profile instead
            # (chrome/browser/ui/views/frame/desktop_browser_frame_aura_linux.cc,
            # GetXdgAppIdForWebApp), so the preview window is
            # "chrome-127.0.0.1__-Default". The host is fixed by the plugin's
            # default `host` setting; the random port is not part of the id.
            {
                match = { class = "chrome-127\\.0\\.0\\.1__-.*"; };
                # Keep typing in the editor; the preview is a display, not a
                # place to work in.
                no_initial_focus = true;
            }
        ];
    };
}
