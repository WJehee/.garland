{ ... }: {
    programs.nixvim = {
        globals.mapleader = " ";
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
        ];
    };
}
