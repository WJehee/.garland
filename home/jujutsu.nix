{ ... }: {
    programs.jujutsu = {
        enable = true;
        settings = {
            user = {
                name = "Wouter Jehee";
                email = "wouter@wouterjehee.com";
            };
            ui = {
                paginate = "never";
                default-command = "log";
            };
        };
    };
}
