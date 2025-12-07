{ ... }: {
    programs.git = {
        enable = true;
        ignores = [
            ".env"
            "_pycache_/"
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
