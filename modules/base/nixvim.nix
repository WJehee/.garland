{ inputs, ... }: {
    # Plain editor for every host. Language servers, completion and the
    # rest of the IDE plugins are in workstation/nixvim.nix.
    flake.modules.nixos.base = { ... }: {
        imports = [ inputs.nixvim.nixosModules.nixvim ];
        programs.nixvim = {
            enable = true;
            # Explicit source suppresses the eval warning caused by the
            # nixvim nixpkgs follows in flake.nix (same value either way)
            nixpkgs.source = inputs.nixpkgs;
            viAlias = true;
            vimAlias = true;
            defaultEditor = true;
            opts = {
                showmode =false;
                number = true;
                hidden = true;
                relativenumber = true;
                errorbells = false;
                expandtab = true;
                smartindent = false;
                fixendofline = false;
                undofile = true;
                scrolloff = 8;
                tabstop = 4;
                softtabstop = 4;
                shiftwidth = 4;
                signcolumn = "yes";
                spelllang = [ "en_us" ];
            };
            # Yank and put go straight through the system clipboard
            clipboard = {
                register = "unnamedplus";
                # wl-clipboard on nvim's own PATH, so this holds inside nix
                # shells and other environments that do not ship it
                providers.wl-copy.enable = true;
            };
            extraConfigLua = ''
                -- Over ssh there is no Wayland socket, so copy through the
                -- terminal with OSC 52: a yank on a server lands on the local
                -- clipboard. nvim only auto-detects OSC 52 while 'clipboard'
                -- is unset, hence the explicit provider. Pasting stays local
                -- (the last yank of this session): the terminal refuses OSC
                -- 52 reads (alacritty osc52 = OnlyCopy), and the query would
                -- otherwise stall every put for ten seconds.
                if vim.env.SSH_TTY and not vim.env.WAYLAND_DISPLAY and not vim.env.DISPLAY then
                    local osc52 = require("vim.ui.clipboard.osc52")
                    local last = { {}, "v" }
                    local function copy(reg)
                        local send = osc52.copy(reg)
                        return function(lines, regtype)
                            last = { lines, regtype }
                            send(lines, regtype)
                        end
                    end
                    local function paste()
                        return last
                    end
                    vim.g.clipboard = {
                        name = "OSC 52 (copy only)",
                        copy = { ["+"] = copy("+"), ["*"] = copy("*") },
                        paste = { ["+"] = paste, ["*"] = paste },
                    }
                end
            '';
            autoCmd = [
                {
                    command = "setlocal spell";
                    event = [
                        "BufEnter"
                        "BufWinEnter"
                    ];
                    pattern = [
                        "*.md"
                        "*.tex"
                    ];
                }
            ];
            plugins.gitsigns.enable = true;
            globals.mapleader = " ";
            keymaps = [
                {
                    # Apply macro in register q and move down
                    mode = "n";
                    key = "Q";
                    action = "@qj";
                }
                {
                    # Apply macro in register q on visual selection
                    mode = "n";
                    key = "Q";
                    action = ":norm @q<CR>";
                }
            ];
        };
    };
}
