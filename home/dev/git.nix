{ ... }: {
    programs.git = {
        enable = true;
        userName = "Wouter Jehee";
        userEmail = "wouter@wouterjehee.com";
        ignores = [
            ".env"
            "_pycache_/"
        ];
        aliases = {
            s = "status";
        };
        extraConfig = {
            credential.helper = "store";
            url = {
                "https://gitlab.esa.int/" = {
                    insteadOf = [
                        "git@gitlab.esa.int:"
                    ];
                };
                "https://gitlab.freedesktop.org/" = {
                    insteadOf = [
                        "git@gitlab.freedesktop.org:"
                    ];
                };
            };
        };
    };
}
