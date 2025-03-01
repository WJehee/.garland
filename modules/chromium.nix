{ pkgs, ... }: {
    programs.chromium = {
        enable = true;        
        extensions = [
            "cjpalhdlnbpafiamejdnhcphjbkeiagm"  # Ublock origin
            "eimadpbcbfnmbkopoojfekhnkhdbieeh"  # Darkreader
            "oboonakemofpalcgghocfoadofidjkkk"  # KeepassXC browser
            "gcknhkkoolaabfmlnjonogaaifnjlfnp"  # Foxyproxy
        ];
        extraOpts = {
            "BrowserSignin" = 0;
            "SyncDisabled" = true;
            "PasswordManagerEnabled" = false;
            "SpellcheckEnabled" = true;
            "SpellcheckLanguage" = [
                "nl"
                "en-US"
            ];
            # "ManagedBookmarks" = [
            #     { "toplevel_name" = "Bookmarks" ;}
            #     {
            #         "name" = "";
            #         "url" = "test.com";
            #     }
            # ];
        };
    };
}
