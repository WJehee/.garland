{ ... }: {
    programs.git = {
        enable = true;
        userName = "Wouter Jehee";
        userEmail = "wouterjehee@tutanota.com";
        ignores = [
            ".env"
            "_pycache_/"
        ];
    };
}
