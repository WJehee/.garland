{
    rust = {
        path = ./rust;
        description = "A rust project";
        welcomeText = ''
            # Getting started
            
            - nix develop
            - cargo init
        '';
    };
    zig = {
        path = ./zig;
        description = "A zig project";
        welcomeText = ''
            # Getting started
            
            - nix develop
            - zig init-exe or zig init-lib
        '';
    };
    # TODO
    elixir = {
        path = ./elixir;
        description = "An elixir project";
        welcomeText = ''
            # Getting started

            - nix develop
            - mix new .

            The name of the folder you are in can only contain letters and _!
        '';
    };
    # TODO
    python = {
        path = ./python;
        description = "A python project";
    };
}
