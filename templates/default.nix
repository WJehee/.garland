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

            - direnv allow
            - rename the package in Cargo.toml
        '';
    };
    zig = {
        path = ./zig;
        description = "A zig project";
        welcomeText = ''
            ## Getting started

            - direnv allow
            - zig init
        '';
    };
    elixir = {
        path = ./elixir;
        description = "An elixir project";
        welcomeText = ''
            ## Getting started

            - direnv allow
            - mix new .
        '';
    };
    python = {
        path = ./python;
        description = "A python project";
        welcomeText = ''
            ## Getting started

            - direnv allow
            - uv init
        '';
    };
    gleam = {
        path = ./gleam;
        description = "A gleam project";
        welcomeText = ''
            ## Getting started

            - direnv allow
            - gleam new .
        '';
    };
    android = {
        path = ./android;
        description = "An android project";
        welcomeText = ''
            ## Getting started

            - direnv allow
            - create the project in this directory with Android Studio
        '';
    };
}
