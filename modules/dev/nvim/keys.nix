{ ... }: {
    programs.nixvim = {
        globals.mapleader = " ";
        keymaps = [
            {
                # Apply macro in register q and move down
                mode = "n";
                key = "Q";
                action = "@qj";
            }
            {
                # Apply macro in register q on visual selection
                mode = "n";
                key = "Q";
                action = ":norm @q<CR>";
            }
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
