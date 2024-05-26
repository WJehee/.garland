{ pkgs, ... }: {
    programs.neovim.plugins = with pkgs.vimPlugins; [
        nvim-treesitter-context
        {
            plugin = nvim-treesitter.withAllGrammars;
            type = "lua";
            config = ''
                require'nvim-treesitter.configs'.setup {
                    highlight = {
                        enable = true,
                        additional_vim_regex_highlighting = false,
                    }
                }
            '';
        }
        rainbow-delimiters-nvim
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
                local capabilities = vim.lsp.protocol.make_client_capabilities()
                capabilities.textDocument.completion.completionItem.snippetSupport = true
                require'lspconfig'.html.setup {
                    capabilities = capabilities,
                }
                require'lspconfig'.htmx.setup{}
                require'lspconfig'.jedi_language_server.setup{}
                require'lspconfig'.nil_ls.setup{}
                require'lspconfig'.clangd.setup{}
                require'lspconfig'.texlab.setup{}
                require'lspconfig'.zls.setup{}
                require'lspconfig'.gleam.setup{}
                require'lspconfig'.rust_analyzer.setup{}
            '';
        }
        vim-elixir
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
        {
            plugin = neogit;
            type = "lua";
            config = ''
                require('neogit').setup()
            '';
        }
        {
            plugin = gitsigns-nvim;
            type = "lua";
            config = ''
                require('gitsigns').setup()
            '';
        }
    ];
}
