{ ... }: {
    imports = [
        ./plugins.nix
    ];
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
            nnoremap("<leader>gs", require('telescope.builtin').git_status)
            nnoremap("<leader>gl", require('telescope.builtin').git_commits)

            nnoremap("<leader>ca", "<cmd>Lspsaga code_action<CR>")
            nnoremap("<leader>rn", "<cmd>Lspsaga rename<CR>")
            nnoremap("<leader>hd", "<cmd>Lspsaga hover_doc<CR>")

            nnoremap("<leader>pd", "<cmd>Lspsaga peek_definition<CR>")
            nnoremap("<leader>gd", "<cmd>Lspsaga goto_definition<CR>")
            nnoremap("<leader>fd", "<cmd>Lspsaga finder<CR>")
        '';
    };
}

