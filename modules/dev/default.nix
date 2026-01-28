{ pkgs, ... }: {
    imports = [
        ./godot.nix
        ./llm.nix
        ./nvim
        ./starship.nix
        ./zsh.nix
    ];
    virtualisation = {
        libvirtd.enable = true;
        docker.enable = true;
    };
    environment.systemPackages = with pkgs; [
        # General
        git
        jujutsu
        just

        # Containers
        docker
        docker-compose
        minikube

        # Asciidoc
        asciidoctor-with-extensions
        asciidoc-full-with-plugins

        nushellPlugins.query
    ];
}
