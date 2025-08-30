{
    default = {
        path = ./default;
        description = "Default project";
    };
    rust = {
        path = ./rust;
        description = "A rust project";
        welcomeText = ''
            ## Getting started
            
            - nix develop
            - cargo init
        '';
    };
    zig = {
        path = ./zig;
        description = "A zig project";
        welcomeText = ''
            ## Getting started
            
            - nix develop
            - zig init
        '';
    };
    elixir = {
        path = ./elixir;
        description = "An elixir project";
        welcomeText = ''
            ## Getting started

            - nix develop
            - mix new .
        '';
    };
    python = {
        path = ./python;
        description = "A python project";
        welcomeText = ''
            ## Getting started

            - nix develop
            - uv init
            - uv venv
        '';
    };
    gleam = {
        path = ./gleam;
        description = "A gleam project";
        welcomeText = ''
            ## Getting started

            - nix develop
            - gleam new .
        '';
    };
    odin = {
        path = ./odin;
        description = "A odin project";
        welcomeText = ''
        ## Getting started

        '';
    };
}
