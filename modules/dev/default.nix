{ lib, pkgs, vars, ... }: let
    cfg = vars.garland.dev;
in {
    imports = []
    ++ lib.optionals (cfg.godot or false) [ ./godot.nix ]
    ++ lib.optionals (cfg.android or false) [ ./android.nix ]
    ++ lib.optionals (cfg.virtualization or true) [ ./virtualization.nix ];

    environment.systemPackages = with pkgs; [

        asciidoctor-with-extensions
        asciidoc-full-with-plugins
    ];
}
