{ ... }: {
    programs.nixvim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
        opts = {
            expandtab = true;
            smartindent = false;
            fixendofline = false;
            undofile = true;
            scrolloff = 8;
            tabstop = 4;
            softtabstop = 4;
            shiftwidth = 4;
            signcolumns = true;
            mapleader = " ";
        };
        # colorscheme = "nord";

        plugins = {
            treesitter.enable = true;
            treesitter-context.enable = true;
            treesitter-refactor.enable = true;
            lsp = {
                enable = true;
                servers = {
                    elixirls.enable = true;
                    emmet-ls.enable = true;
                    gleam.enable = true;
                    gopls.enable = true;
                    html.enable = true;
                    nil-ls.enable = true;
                    pyright.enable = true;
                    rust-analyzer = {
                        enable = true;
                    };
                    zls.enable = true;
                };
            };

            gitsigns = {
                enable = true;
            };
            rainbow-delimiters.enable = true;

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
            lspsaga = {
                enable = true;
                codeAction.keys.exec = "<leader>ca";
                rename.keys.exec = "<leader>rn";
                
            };

            neogit.enable = true;
        };
    };
}
