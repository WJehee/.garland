{ ... }: {
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
            "DnsOverHttpsMode" = "secure";
            "DnsOverHttpsTemplates" = [
                "https://dns.quad9.net/dns-query{?dns}"
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
