{
    flake.modules.nixos."dev/asciidoc" = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            asciidoctor-with-extensions
            asciidoc-full-with-plugins
        ];
    };
}
