{ pkgs, ... }: {
    programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
        extraLuaConfig = ''
            vim.opt.completeopt={ "menu", "menuone", "noselect" }
            vim.opt.showmode = false
            vim.opt.hlsearch = false
            vim.opt.exrc = true
            vim.opt.number = true
            vim.opt.hidden = true
            vim.opt.relativenumber = true
            vim.opt.errorbells = false
            vim.opt.wrap = false
            vim.opt.swapfile = false
            vim.opt.backup = false
            vim.opt.expandtab = true
            vim.opt.smartindent = false
            vim.opt.fixendofline = false
            vim.opt.undofile = true
            vim.opt.scrolloff=8
            vim.opt.tabstop=4
            vim.opt.softtabstop=4
            vim.opt.shiftwidth=4
            vim.opt.shell="/bin/zsh"
            vim.opt.clipboard="unnamedplus"
            vim.opt.signcolumn = "yes"
            vim.g.mapleader = " "

            local function keymap()
                local M = {}
                local function bind(op, outer_opts)
                    outer_opts = outer_opts or {noremap = true}
                    return function(lhs, rhs, opts)
                        opts = vim.tbl_extend("force",
                                outer_opts,
                                opts or {}
                                )
                        vim.keymap.set(op, lhs, rhs, opts)
                    end
                end
                M.nmap = bind("n", {noremap = false})
                M.nnoremap = bind("n")
                M.vnoremap = bind("v")
                M.xnoremap = bind("x")
                M.inoremap = bind("i")
                return M
            end

            local nnoremap = keymap().nnoremap

            nnoremap("<Up>", "<Nop>")
            nnoremap("<Down>", "<Nop>")
            nnoremap("<Left>", "<Nop>")
            nnoremap("<Right>", "<Nop>")

            nnoremap("<leader>ff", require('telescope.builtin').find_files)
            nnoremap("<leader>fg", require('telescope.builtin').live_grep)
            nnoremap("<leader>fb", require('telescope.builtin').buffers)

            nnoremap("<leader>ca", "<cmd>Lspsaga code_action<CR>")
            nnoremap("<leader>rn", "<cmd>Lspsaga rename<CR>")
            nnoremap("<leader>hd", "<cmd>Lspsaga hover_doc<CR>")

            nnoremap("<leader>pd", "<cmd>Lspsaga peek_definition<CR>")
            nnoremap("<leader>gd", "<cmd>Lspsaga goto_definition<CR>")
            nnoremap("<leader>fd", "<cmd>Lspsaga finder<CR>")
        '';
        plugins = with pkgs.vimPlugins; [
            nvim-treesitter.withAllGrammars
            nvim-treesitter-context
            nvim-web-devicons
            vim-commentary
            {
                plugin = nvim-cmp;
                type = "lua";
                config = ''
                    local has_words_before = function()
                      unpack = unpack or table.unpack
                      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
                    end

                    local cmp = require('cmp')

                    cmp.setup({
                        window = {},
                        mapping = {
                            ['<CR>'] = cmp.mapping.confirm({ select = true }),
                            ["<Tab>"] = cmp.mapping(function(fallback)
                                if cmp.visible() then
                                    cmp.select_next_item()
                                elseif has_words_before() then
                                    cmp.complete()
                                else
                                    fallback()
                                end
                            end, { "i", "s" }),
                            ["<S-Tab>"] = cmp.mapping(function(fallback)
                                if cmp.visible() then
                                    cmp.select_prev_item()
                                else
                                    fallback()
                                end
                            end, { "i", "s" }),
                        },
                        sources = cmp.config.sources({
                            { name = 'nvim_lsp' },
                        })
                    })
                '';
            }
            luasnip
            cmp-nvim-lsp
            {
                plugin = nvim-lspconfig;
                type = "lua";
                config = ''
                    local lsp = require('lsp-zero')
                    require'lspconfig'.jedi_language_server.setup{}
                    require'lspconfig'.nil_ls.setup{}
                    require'lspconfig'.clangd.setup{}
                    require'lspconfig'.texlab.setup{}
                    require'lspconfig'.elixirls.setup{
                        cmd = { "/run/current-system/sw/bin/elixir-ls" }
                    }
                '';
            }
            vim-elixir
            {
                plugin = rust-tools-nvim;
                type = "lua";
                config = ''
                    local rt = require("rust-tools")

                    rt.setup({
                        server = {
                            on_attach = function(_, bufnr)
                                -- Hover actions
                                vim.keymap.set("n", "<Leader>ha", rt.hover_actions.hover_actions, { buffer = bufnr })
                            end,
                        },
                    })
                '';
            }
            {
                plugin = lsp-zero-nvim;
                type = "lua";
                config = ''
                    local lsp = require('lsp-zero')
                    lsp.preset('recommended')

                    lsp.on_attach(function(client, bufnr)
                            local opts = {buffer = bufnr, remap=false}

                            vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
                            end)

                    lsp.setup()
                    '';
            }
            telescope-nvim
            popup-nvim
            plenary-nvim
            {
                plugin = lspsaga-nvim;
                type = "lua";
                config = ''
                    local saga = require('lspsaga')
                    saga.setup({})
                '';
            }
            # TODO: add codeium, for now auth does not work
            # codeium-vim
        ];
    };
}

