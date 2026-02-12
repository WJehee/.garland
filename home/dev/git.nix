{ ... }: {
    programs.git = {
        enable = true;
        ignores = [
            ".direnv/"
            ".env"
            "_pycache_/"
            ".claude/"
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
