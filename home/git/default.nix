{ ... }: {
    programs.git = {
        enable = true;
        userName = "Wouter Jehee";
        userEmail = "wouterjehee@tutanota.com";
        ignores = [
            ".env"
            "_pycache_/"
        ];
        extraConfig = {
            credential.helper = "store";
            url = {
                "https://gitlab.esa.int/" = {
                    insteadOf = [
                        "git@gitlab.esa.int:"
                    ];
                };
            };
        };
    };
}
