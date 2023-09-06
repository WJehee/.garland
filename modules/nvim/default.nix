{ pkgs, ... }: {
    programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
        plugins  = with pkgs.vimPlugins; [
            vim-airline

            nvim-treesitter.withAllGrammars
            nvim-web-devicons
            nvim-comment
            nvim-lspconfig
            nvim-cmp
            cmp-nvim-lsp

            rust-tools-nvim
            flutter-tools-nvim
            lsp-zero-nvim
            telescope-nvim
            popup-nvim
            plenary-nvim
            lspsaga-nvim
            mason-nvim
            mason-lspconfig-nvim
        ];
    };
}
