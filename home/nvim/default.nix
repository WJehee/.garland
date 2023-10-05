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

            nnoremap("<leader>ff", require('telescope.builtin').find_files)
            nnoremap("<leader>fg", require('telescope.builtin').live_grep)
            nnoremap("<leader>fb", require('telescope.builtin').buffers)

            nnoremap("<leader>ca", "<cmd>Lspsaga code_action<CR>")
            nnoremap("<leader>rn", "<cmd>Lspsaga rename<CR>")
            nnoremap("<leader>gd", "<cmd>Lspsaga peek_definition<CR>")
            nnoremap("<leader>hd", "<cmd>Lspsaga hover_doc<CR>")
        '';
        plugins  = with pkgs.vimPlugins; [
            nvim-treesitter.withAllGrammars
            nvim-treesitter-context
            nvim-web-devicons
            luasnip
            {
                plugin = nvim-cmp;
                type = "lua";
                config = ''
                    local cmp = require('cmp')
                    cmp.setup({
                        snippet = {
                            expand = function(args)
                                luasnip.lsp_expand(args.body)
                            end,
                        },
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
                                elseif luasnip.jumpable(-1) then
                                    luasnip.jump(-1)
                                else
                                    fallback()
                                end
                            end, { "i", "s" }),
                        },
                        sources = cmp.config.sources({
                            { name = 'nvim_lsp' },
                            { name = 'luasnip' }
                        })
                    })
                '';
            }
        vim-commentary
        cmp-nvim-lsp
        flutter-tools-nvim
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
        mason-nvim
        mason-lspconfig-nvim
        rust-vim
        {
            plugin = nvim-lspconfig;
            type = "lua";
            config = '' 
                local lspconfig = require('lspconfig')

                function add_lsp(binary, server, options)
                if not options["cmd"] then options["cmd"] = { binary, unpack(options["cmd_args"] or {}) } end
                    if vim.fn.executable(binary) == 1 then server.setup(options) end
                        end

                            add_lsp("docker-langserver", lspconfig.dockerls, {})
                            add_lsp("bash-language-server", lspconfig.bashls, {})
                            add_lsp("nil", lspconfig.nil_ls, {})
                            add_lsp("pylsp", lspconfig.pylsp, {})
                            add_lsp("dart", lspconfig.dartls, {})
                            add_lsp("haskell-language-server", lspconfig.hls, {
                                    cmd_args = { "--lsp" }
                                    })
            '';
        }
        { 
            plugin = rust-tools-nvim;
            type = "lua";
            config = ''
                local rust_tools = require('rust-tools')
                add_lsp("rust-analyzer", rust_tools, {
                        tools = { autoSetHints = true }
                        })
            '';
        }
        ];
    };
}

