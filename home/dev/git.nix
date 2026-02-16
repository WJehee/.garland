{ ... }: {
    programs.git = {
        enable = true;
        ignores = [
            ".direnv/"
            ".env"
            "_pycache_/"
            ".claude/"
            "result"
        ];

        settings = {
            user = {
                name = "Wouter Jehee";
                email = "wouter@wouterjehee.com";
            };
            alias = {
                s = "status";
            };
            credential.helper = "store";
        };
    };
}
