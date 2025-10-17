{ ... }: {
    imports = [
        ./keys.nix
    ];
    programs.nixvim = {
        enable = true;
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
        clipboard.register = "unnamedplus";
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
            {
                command = "TSBufEnable highlight";
                event = [
                    "BufEnter"
                    "BufWinEnter"
                ];
                pattern = [ "*" ];
            }
        ];

        plugins = {
            treesitter = {
                enable = true;
                settings.indent.enable = true;
            };
            treesitter-context.enable = true;
            treesitter-refactor.enable = true;
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
            cmp-treesitter.enable = true;

            gitsigns = {
                enable = true;
            };
            rainbow-delimiters.enable = true;
            web-devicons = {
                enable = true;
                settings = {
                    color_icons = true;
                    strict = true;
                };
            };

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
            neogit.enable = true;
        };
    };
}
