{
    default = {
        path = ./default;
        description = "Default project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
        '';
    };
    rust = {
        path = ./rust;
        description = "A rust project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
        '';
    };
    zig = {
        path = ./zig;
        description = "A zig project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
            - zig init
        '';
    };
    elixir = {
        path = ./elixir;
        description = "An elixir project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
            - mix new .
        '';
    };
    python = {
        path = ./python;
        description = "A python project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
            - uv init
        '';
    };
    gleam = {
        path = ./gleam;
        description = "A gleam project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
            - gleam new .
        '';
    };
    android = {
        path = ./android;
        description = "An android project";
        welcomeText = ''
            ## Getting started

            - just init      # set the project name from the directory name
            - direnv allow
            - create the project in this directory with Android Studio
        '';
    };
}
