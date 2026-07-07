{
    flake.modules.nixos.dev = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            asciidoctor-with-extensions
            asciidoc-full-with-plugins
            gh
        ];
    };
}
