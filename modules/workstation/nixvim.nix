{
    # IDE half of the editor: language servers, completion, treesitter and
    # the git/telescope tooling. The base editor is in base/nixvim.nix.
    flake.modules.nixos.workstation = { ... }: {
        programs.nixvim = {
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
            keymaps = [
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
