{ inputs, ... }: {
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

            plugins = {
                # Language support
                treesitter = {
                    enable = true;
                    settings.indent.enable = true;
                };
                treesitter-context.enable = true;
                lsp = {
                    enable = true;
                    keymaps = {
                        lspBuf = {
                            gd = "definition";
                            gi = "implementation";
                        };
                    };
                    servers = {
                        clangd.enable = true;
                        dockerls.enable = true;
                        elixirls.enable = true;
                        emmet_ls.enable = true;
                        eslint.enable = true;
                        gleam.enable = true;
                        gopls.enable = true;
                        html.enable = true;
                        nixd.enable = true;
                        nushell.enable = true;
                        ols.enable = true;
                        pyright.enable = true;
                        rust_analyzer = {
                            enable = true;
                            installCargo = false;
                            installRustc = false;
                        };
                        tailwindcss.enable = true;
                        zls.enable = true;
                        texlab.enable = true;
                    };
                };
                # tailwind-tools.enable = true;
                lspsaga.enable = true;
                luasnip.enable = true;
                cmp = {
                    enable = true;
                    autoEnableSources = true;
                    settings = {
                        sources = [
                            { name = "nvim_lsp"; }
                            { name = "luasnip"; }
                            { name = "path"; }
                            { name = "treesitter"; }
                        ];
                        mapping = {
                            "<CR>" = "cmp.mapping.confirm({ select = true })";
                            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
                            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
                        };
                    };
                };
                # cmp-treesitter.enable = true;

                # Visual
                gitsigns.enable = true;
                rainbow-delimiters.enable = true;
                web-devicons = {
                    enable = true;
                    settings = {
                        color_icons = true;
                        strict = true;
                    };
                };

                # Tools
                telescope = {
                    enable = true;
                    keymaps = {
                        "<leader>ff" = "find_files";
                        "<leader>fg" = "live_grep";
                        "<leader>fb" = "buffers";
                        "<leader>gs" = "git_status";
                        "<leader>gl" = "git_commits";
                    };
                };
                # undotree.enable = true;
                neogit.enable = true;
            };
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
                {
                    mode = "n";
                    key = "<leader>ca";
                    action = "<cmd>Lspsaga code_action<CR>";
                }
                {
                    mode = "n";
                    key = "<leader>rn";
                    action = "<cmd>Lspsaga rename<CR>";
                }
                {
                    mode = "n";
                    key = "<leader>hd";
                    action = "<cmd>Lspsaga hover_doc<CR>";
                }
                {
                    mode = "n";
                    key = "<leader>pd";
                    action = "<cmd>Lspsaga peek_definition<CR>";
                }
                {
                    mode = "n";
                    key = "<leader>gd";
                    action = "<cmd>Lspsaga goto_definition<CR>";
                }
                {
                    mode = "n";
                    key = "<leader>fd";
                    action = "<cmd>Lspsaga finder<CR>";
                }
                {
                    # Sort tailwind classes in quotes
                    mode = "n";
                    key = "<leader>tws";
                    action = "vi\":TailwindSortSelectionSync<CR>";
                }
            ];
        };
    };
}
