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
        ];

        plugins = {
            treesitter.enable = true;
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
                    elixirls.enable = true;
                    emmet-ls.enable = true;
                    gleam.enable = true;
                    gopls.enable = true;
                    html.enable = true;
                    nil-ls.enable = true;
                    pyright.enable = true;
                    rust-analyzer = {
                        enable = true;
                        installCargo = false;
                        installRustc = false;
                    };
                    zls.enable = true;
                    texlab.enable = true;
                };
            };
            lspsaga.enable = true;
            luasnip.enable = true;

            cmp-nvim-lsp.enable = true;
            cmp_luasnip.enable = true;
            cmp = {
                enable = true;
                settings = {
                    sources = [
                        { name = "nvim_lsp"; }
                        { name = "luasnip"; }
                    ];
                    mapping = {
                        "<CR>" = "cmp.mapping.confirm({ select = true })";
                        "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
                        "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
                    };
                };
            };

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
